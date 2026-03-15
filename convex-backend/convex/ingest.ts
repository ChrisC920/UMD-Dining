import { mutation } from "./_generated/server";
import { v } from "convex/values";

// Upsert a food record with all its relations; called by the Python scraper
export const upsertFood = mutation({
  args: {
    name: v.string(),
    link: v.string(),
    servingSize: v.string(),
    servingsPerContainer: v.string(),
    caloriesPerServing: v.string(),
    totalFat: v.string(),
    saturatedFat: v.string(),
    transFat: v.string(),
    totalCarbohydrates: v.string(),
    dietaryFiber: v.string(),
    totalSugars: v.string(),
    addedSugars: v.string(),
    cholesterol: v.string(),
    sodium: v.string(),
    protein: v.string(),
    allergens: v.array(v.string()),
    diningHall: v.string(),
    locationNum: v.number(),
    mealType: v.string(),
    section: v.string(),
    date: v.string(),
  },
  handler: async (ctx, args) => {
    const { allergens, diningHall, locationNum, mealType, section, date, ...foodFields } = args;

    // Upsert food
    let foodId;
    const existing = await ctx.db
      .query("foods")
      .withIndex("by_name_link", (q) => q.eq("name", args.name).eq("link", args.link))
      .first();
    if (existing) {
      await ctx.db.patch(existing._id, foodFields);
      foodId = existing._id;
    } else {
      foodId = await ctx.db.insert("foods", foodFields);
    }

    // Upsert diningHall
    let hall = await ctx.db
      .query("diningHalls")
      .withIndex("by_name", (q) => q.eq("name", diningHall))
      .first();
    if (!hall) {
      const hallId = await ctx.db.insert("diningHalls", { name: diningHall, locationNum });
      hall = await ctx.db.get(hallId);
    }

    // Upsert mealType
    let mt = await ctx.db
      .query("mealTypes")
      .withIndex("by_name", (q) => q.eq("name", mealType))
      .first();
    if (!mt) {
      const mtId = await ctx.db.insert("mealTypes", { name: mealType });
      mt = await ctx.db.get(mtId);
    }

    // Upsert section
    let sec = await ctx.db
      .query("sections")
      .withIndex("by_name", (q) => q.eq("name", section))
      .first();
    if (!sec) {
      const secId = await ctx.db.insert("sections", { name: section });
      sec = await ctx.db.get(secId);
    }

    // Upsert date
    let dateDoc = await ctx.db
      .query("dates")
      .withIndex("by_date", (q) => q.eq("date", date))
      .first();
    if (!dateDoc) {
      const dateId = await ctx.db.insert("dates", { date });
      dateDoc = await ctx.db.get(dateId);
    }

    // Upsert allergens + foodAllergens
    for (const allergenName of allergens) {
      let al = await ctx.db
        .query("allergens")
        .withIndex("by_name", (q) => q.eq("name", allergenName))
        .first();
      if (!al) {
        const alId = await ctx.db.insert("allergens", { name: allergenName });
        al = await ctx.db.get(alId);
      }
      const fa = await ctx.db
        .query("foodAllergens")
        .withIndex("by_food", (q) => q.eq("foodId", foodId))
        .filter((q) => q.eq(q.field("allergenId"), al!._id))
        .first();
      if (!fa) {
        await ctx.db.insert("foodAllergens", { foodId, allergenId: al!._id });
      }
    }

    // Upsert foodRelation
    const relExists = await ctx.db
      .query("foodRelations")
      .withIndex("by_date_hall", (q) =>
        q.eq("dateId", dateDoc!._id).eq("diningHallId", hall!._id)
      )
      .filter((q) =>
        q.and(
          q.eq(q.field("foodId"), foodId),
          q.eq(q.field("mealTypeId"), mt!._id),
          q.eq(q.field("sectionId"), sec!._id)
        )
      )
      .first();
    if (!relExists) {
      await ctx.db.insert("foodRelations", {
        foodId,
        diningHallId: hall!._id,
        dateId: dateDoc!._id,
        mealTypeId: mt!._id,
        sectionId: sec!._id,
      });
    }

    return foodId;
  },
});
