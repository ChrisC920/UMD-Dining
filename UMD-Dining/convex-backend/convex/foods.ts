import { query } from "./_generated/server";
import { v } from "convex/values";

export const getFoodsByFilters = query({
  args: {
    date: v.optional(v.string()),
    diningHallNames: v.optional(v.array(v.string())),
    mealTypeNames: v.optional(v.array(v.string())),
    sectionNames: v.optional(v.array(v.string())),
    allergenExclusions: v.optional(v.array(v.string())),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const dateStr = args.date ?? new Date().toISOString().split("T")[0];
    const dateDoc = await ctx.db
      .query("dates")
      .withIndex("by_date", (q) => q.eq("date", dateStr))
      .first();
    if (!dateDoc) return { foods: [] };

    let hallIds: string[] | null = null;
    if (args.diningHallNames && args.diningHallNames.length > 0) {
      const halls = await Promise.all(
        args.diningHallNames.map((n) =>
          ctx.db.query("diningHalls").withIndex("by_name", (q) => q.eq("name", n)).first()
        )
      );
      hallIds = halls.filter(Boolean).map((h) => h!._id);
    }

    let relations = await ctx.db
      .query("foodRelations")
      .withIndex("by_date", (q) => q.eq("dateId", dateDoc._id))
      .collect();

    if (hallIds) {
      relations = relations.filter((r) => hallIds!.includes(r.diningHallId));
    }

    if (args.mealTypeNames && args.mealTypeNames.length > 0) {
      const mts = await Promise.all(
        args.mealTypeNames.map((n) =>
          ctx.db.query("mealTypes").withIndex("by_name", (q) => q.eq("name", n)).first()
        )
      );
      const mtIds = mts.filter(Boolean).map((m) => m!._id);
      relations = relations.filter((r) => mtIds.includes(r.mealTypeId));
    }

    if (args.sectionNames && args.sectionNames.length > 0) {
      const secs = await Promise.all(
        args.sectionNames.map((n) =>
          ctx.db.query("sections").withIndex("by_name", (q) => q.eq("name", n)).first()
        )
      );
      const secIds = secs.filter(Boolean).map((s) => s!._id);
      relations = relations.filter((r) => secIds.includes(r.sectionId));
    }

    // Deduplicate by foodId
    const seen = new Set<string>();
    const uniqueRelations = relations.filter((r) => {
      if (seen.has(r.foodId)) return false;
      seen.add(r.foodId);
      return true;
    });

    const limit = args.limit ?? 100;
    const sliced = uniqueRelations.slice(0, limit);

    const foods = await Promise.all(
      sliced.map(async (rel) => {
        const food = await ctx.db.get(rel.foodId);
        if (!food) return null;

        const allergenJoins = await ctx.db
          .query("foodAllergens")
          .withIndex("by_food", (q) => q.eq("foodId", rel.foodId))
          .collect();
        const allergens = await Promise.all(
          allergenJoins.map((aj) => ctx.db.get(aj.allergenId))
        );

        const hall = await ctx.db.get(rel.diningHallId);
        const mealType = await ctx.db.get(rel.mealTypeId);
        const section = await ctx.db.get(rel.sectionId);
        const date = await ctx.db.get(rel.dateId);

        return {
          ...food,
          allergens: allergens.filter(Boolean).map((a) => a!.name),
          diningHall: hall?.name ?? "",
          mealType: mealType?.name ?? "",
          section: section?.name ?? "",
          date: date?.date ?? "",
        };
      })
    );

    let result = foods.filter(Boolean) as any[];

    if (args.allergenExclusions && args.allergenExclusions.length > 0) {
      result = result.filter(
        (food) => !food.allergens.some((a: string) => args.allergenExclusions!.includes(a))
      );
    }

    return { foods: result };
  },
});

export const getFoodById = query({
  args: { foodId: v.id("foods") },
  handler: async (ctx, args) => {
    const food = await ctx.db.get(args.foodId);
    if (!food) return null;

    const allergenJoins = await ctx.db
      .query("foodAllergens")
      .withIndex("by_food", (q) => q.eq("foodId", args.foodId))
      .collect();
    const allergens = await Promise.all(
      allergenJoins.map((aj) => ctx.db.get(aj.allergenId))
    );

    // Get all relations for this food to gather diningHalls, mealTypes, sections
    const relations = await ctx.db
      .query("foodRelations")
      .withIndex("by_food", (q) => q.eq("foodId", args.foodId))
      .collect();

    const diningHalls = [...new Set(
      (await Promise.all(relations.map((r) => ctx.db.get(r.diningHallId))))
        .filter(Boolean).map((h) => h!.name)
    )];
    const mealTypes = [...new Set(
      (await Promise.all(relations.map((r) => ctx.db.get(r.mealTypeId))))
        .filter(Boolean).map((m) => m!.name)
    )];
    const sections = [...new Set(
      (await Promise.all(relations.map((r) => ctx.db.get(r.sectionId))))
        .filter(Boolean).map((s) => s!.name)
    )];
    const dates = [...new Set(
      (await Promise.all(relations.map((r) => ctx.db.get(r.dateId))))
        .filter(Boolean).map((d) => d!.date)
    )];

    return {
      ...food,
      allergens: allergens.filter(Boolean).map((a) => a!.name),
      diningHalls,
      mealTypes,
      sections,
      dates,
    };
  },
});
