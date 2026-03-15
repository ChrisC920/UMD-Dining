import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const addFavorite = mutation({
  args: { clerkId: v.string(), foodId: v.id("foods") },
  handler: async (ctx, { clerkId, foodId }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", clerkId))
      .first();
    if (!user) throw new Error("User not found");
    const exists = await ctx.db
      .query("favorites")
      .withIndex("by_user_food", (q) => q.eq("userId", user._id).eq("foodId", foodId))
      .first();
    if (!exists) await ctx.db.insert("favorites", { userId: user._id, foodId });
  },
});

export const removeFavorite = mutation({
  args: { clerkId: v.string(), foodId: v.id("foods") },
  handler: async (ctx, { clerkId, foodId }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", clerkId))
      .first();
    if (!user) throw new Error("User not found");
    const fav = await ctx.db
      .query("favorites")
      .withIndex("by_user_food", (q) => q.eq("userId", user._id).eq("foodId", foodId))
      .first();
    if (fav) await ctx.db.delete(fav._id);
  },
});

export const getUserFavorites = query({
  args: { clerkId: v.string() },
  handler: async (ctx, { clerkId }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", clerkId))
      .first();
    if (!user) return [];
    const favs = await ctx.db
      .query("favorites")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .collect();

    const foods = await Promise.all(
      favs.map(async (f) => {
        const food = await ctx.db.get(f.foodId);
        if (!food) return null;
        const allergenJoins = await ctx.db
          .query("foodAllergens")
          .withIndex("by_food", (q) => q.eq("foodId", f.foodId))
          .collect();
        const allergens = await Promise.all(
          allergenJoins.map((aj) => ctx.db.get(aj.allergenId))
        );
        return { ...food, allergens: allergens.filter(Boolean).map((a) => a!.name) };
      })
    );
    return foods.filter(Boolean);
  },
});
