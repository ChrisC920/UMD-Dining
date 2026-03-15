import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Master tables
  foods: defineTable({
    name: v.string(),
    link: v.string(),            // nutrition detail URL
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
  })
    .index("by_name_link", ["name", "link"]),

  diningHalls: defineTable({
    name: v.string(),
    locationNum: v.number(),     // 19, 51, 16
    imageAsset: v.optional(v.string()),
  })
    .index("by_name", ["name"]),

  mealTypes: defineTable({
    name: v.string(),            // Breakfast, Lunch, Dinner, Brunch
  })
    .index("by_name", ["name"]),

  sections: defineTable({
    name: v.string(),
  })
    .index("by_name", ["name"]),

  dates: defineTable({
    date: v.string(),            // YYYY-MM-DD
  })
    .index("by_date", ["date"]),

  allergens: defineTable({
    name: v.string(),
  })
    .index("by_name", ["name"]),

  // Junction tables
  foodAllergens: defineTable({
    foodId: v.id("foods"),
    allergenId: v.id("allergens"),
  })
    .index("by_food", ["foodId"])
    .index("by_allergen", ["allergenId"]),

  // The main relation: each row = one (food, hall, date, mealType, section) tuple
  foodRelations: defineTable({
    foodId: v.id("foods"),
    diningHallId: v.id("diningHalls"),
    dateId: v.id("dates"),
    mealTypeId: v.id("mealTypes"),
    sectionId: v.id("sections"),
  })
    .index("by_date_hall", ["dateId", "diningHallId"])
    .index("by_food", ["foodId"])
    .index("by_date", ["dateId"]),

  // User tables
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
  })
    .index("by_clerk_id", ["clerkId"]),

  userPreferences: defineTable({
    userId: v.id("users"),
    likesYahentamitsi: v.optional(v.boolean()),
    likes251North: v.optional(v.boolean()),
    likesSouth: v.optional(v.boolean()),
    allergicToSesame: v.optional(v.boolean()),
    allergicToFish: v.optional(v.boolean()),
    allergicToNuts: v.optional(v.boolean()),
    allergicToShellfish: v.optional(v.boolean()),
    dairyFree: v.optional(v.boolean()),
    eggFree: v.optional(v.boolean()),
    allergicToSoy: v.optional(v.boolean()),
    glutenFree: v.optional(v.boolean()),
    isVegan: v.optional(v.boolean()),
    isVegetarian: v.optional(v.boolean()),
    isHalal: v.optional(v.boolean()),
    likesAmerican: v.optional(v.boolean()),
    likesMexican: v.optional(v.boolean()),
    likesItalian: v.optional(v.boolean()),
    likesAsian: v.optional(v.boolean()),
    likesIndian: v.optional(v.boolean()),
    likesMediterranean: v.optional(v.boolean()),
    likesAfrican: v.optional(v.boolean()),
    likesMiddleEastern: v.optional(v.boolean()),
  })
    .index("by_user", ["userId"]),

  favorites: defineTable({
    userId: v.id("users"),
    foodId: v.id("foods"),
  })
    .index("by_user", ["userId"])
    .index("by_user_food", ["userId", "foodId"]),
});
