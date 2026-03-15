import time
import scrapy
from scrapy import signals
from datetime import datetime
from pytz import timezone
from UMD_Web_Scraper.settings import convex_client

scraped_data = []

class CrawlingSpider(scrapy.Spider):

    HALL_LOCATION_NUMS = {
        "Yahentamitsi": 19,
        "251 North": 51,
        "South": 16,
    }

    def __init__(self, name=None, **kwargs):
        super().__init__(name, **kwargs)
        self.start_time = time.time()

    def _hall_location_num(self, name: str) -> int:
        return self.HALL_LOCATION_NUMS.get(name, 0)

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(CrawlingSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def spider_closed(self, spider, reason):
        tz = timezone('America/New_York')
        today_date = datetime.now(tz).strftime("%Y-%m-%d")

        print(f"Uploading {len(scraped_data)} items to Convex...")
        for i, data in enumerate(scraped_data):
            convex_client.mutation("ingest:upsertFood", {
                "name": data["name"],
                "link": data["link"],
                "servingSize": data["serving_size"],
                "servingsPerContainer": data["servings_per_container"].replace(" servings per container", ""),
                "caloriesPerServing": data["calories_per_serving"].replace("\xa0", ""),
                "totalFat": data["total_fat"],
                "saturatedFat": data["saturated_fat"].replace("\xa0", "").replace("Saturated Fat", ""),
                "transFat": data["trans_fat"].replace("Fat", "").replace("\xa0", ""),
                "totalCarbohydrates": data["total_carbohydrates"],
                "dietaryFiber": data["dietary_fiber"].replace("\xa0", "").replace("Dietary Fiber", ""),
                "totalSugars": data["total_sugars"].replace("\xa0", "").replace("Total Sugars", ""),
                "addedSugars": data["added_sugars"].replace("\xa0", "")[9:].replace(" Added Sugars", ""),
                "cholesterol": data["cholesterol"],
                "sodium": data["sodium"],
                "protein": data["protein"],
                "allergens": data.get("allergens", []),
                "diningHall": data["dining_hall"],
                "locationNum": self._hall_location_num(data["dining_hall"]),
                "mealType": data["meal_type"],
                "section": data["section"].strip(),
                "date": today_date,
            })
            if (i + 1) % 50 == 0:
                print(f"  Uploaded {i + 1}/{len(scraped_data)}...")

        elapsed = time.time() - self.start_time
        print(f"Done. Scraped and uploaded {len(scraped_data)} items in {elapsed:.1f}s")

    tz = timezone('America/New_York')
    today_date = datetime.now(tz).strftime("%m/%d/%Y")
    # today_date = "3/01/2026"
    name = "mycrawler"
    allow_domains = ["nutrition.umd.edu"]
    start_urls = [f"https://nutrition.umd.edu/?locationNum=19&dtdate={today_date}",
                  f"https://nutrition.umd.edu/?locationNum=51&dtdate={today_date}",
                  f"https://nutrition.umd.edu/?locationNum=16&dtdate={today_date}"]

    def parse(self, response, **kwargs):
        dining_hall = response.url[39:41]
        if dining_hall == "51":
            dining_hall = "251 North"
        elif dining_hall == "19":
            dining_hall = "Yahentamitsi"
        elif dining_hall == "16":
            dining_hall = "South"
        else:
            dining_hall = "Unknown"

        num_meal_types = len(response.css(".tab-pane").getall())
        meal_type_list = []
        if num_meal_types == 3:
            breakfast_type = response.css("#pane-1")
            lunch_type = response.css("#pane-2")
            dinner_type = response.css("#pane-3")
            meal_type_list.append(breakfast_type)
            meal_type_list.append(lunch_type)
            meal_type_list.append(dinner_type)
        elif num_meal_types == 2:
            brunch_type = response.css("#pane-1")
            dinner_type = response.css("#pane-2")
            meal_type_list.append(brunch_type)
            meal_type_list.append(dinner_type)

        for meal_type in meal_type_list:
            section_list = meal_type.css(".card-body")
            for curr_section in section_list:
                section = curr_section.css("h5.card-title::text").get()
                rows = curr_section.css(".menu-item-row")
                for row in rows:
                    allergens = row.css(".nutri-icon::attr(title)").getall()
                    item = row.css(".menu-item-name")
                    link = "https://nutrition.umd.edu/" + item.css("::attr(href)").get()
                    yield response.follow(link, callback=self.parse_item,
                                          cb_kwargs={"section": section, "dining_hall": dining_hall, "meal_type": meal_type, "num_meal_types": num_meal_types, "allergens": allergens})

    @staticmethod
    def parse_item(response, section, dining_hall, meal_type, num_meal_types, allergens):
        item = {
            "name": response.css("h2::text").get().title(),
            "dining_hall": dining_hall,
            "meal_type": convert_meal_type(meal_type, num_meal_types),
            "section": section,
            "link": response.url,
            "serving_size": response.css(".nutfactsservsize::text")[1].get().lower(),
            "servings_per_container": response.css(".nutfactsservpercont::text").get().lower(),
            "calories_per_serving": response.css("td p::text")[1].get(),
            "total_fat": response.css(".nutfactstopnutrient::text")[0].get(),
            "saturated_fat": response.css(".nutfactstopnutrient::text")[2].get(),
            "trans_fat": response.css(".nutfactstopnutrient::text")[5].get(),
            "total_carbohydrates": response.css(".nutfactstopnutrient::text")[1].get(),
            "dietary_fiber": response.css(".nutfactstopnutrient::text")[3].get(),
            "total_sugars": response.css(".nutfactstopnutrient::text")[6].get(),
            "added_sugars": response.css(".nutfactstopnutrient::text")[8].get(),
            "cholesterol": response.css(".nutfactstopnutrient::text")[7].get(),
            "sodium": response.css(".nutfactstopnutrient::text")[9].get(),
            "protein": response.css(".nutfactstopnutrient::text")[10].get(),
            "allergens": allergens
        }
        scraped_data.append(item)


def convert_meal_type(meal_type_selector, num_meal_types):
    meal_type_id = meal_type_selector.attrib["id"]
    if num_meal_types == 3:
        if meal_type_id == 'pane-1':
            return 'Breakfast'
        elif meal_type_id == 'pane-2':
            return 'Lunch'
        elif meal_type_id == 'pane-3':
            return 'Dinner'
    else:
        if meal_type_id == 'pane-1':
            return 'Brunch'
        elif meal_type_id == 'pane-2':
            return 'Dinner'
    raise Exception('Unknown meal')

def convert_allergen(allergen_text):
    match allergen_text:
        case 'Contains sesame':
            return 'Sesame'
