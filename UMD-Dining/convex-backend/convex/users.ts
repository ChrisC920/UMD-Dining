import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const upsertUser = mutation({
  args: { clerkId: v.string(), email: v.string(), name: v.string() },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first();
    if (existing) {
      await ctx.db.patch(existing._id, { email: args.email, name: args.name });
      return existing._id;
    }
    return ctx.db.insert("users", args);
  },
});

export const getUser = query({
  args: { clerkId: v.string() },
  handler: async (ctx, args) =>
    ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .first(),
});

export const upsertPreferences = mutation({
  args: {
    clerkId: v.string(),
    preferences: v.any(),
  },
  handler: async (ctx, { clerkId, preferences }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", clerkId))
      .first();
    if (!user) throw new Error("User not found");

    const existing = await ctx.db
      .query("userPreferences")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .first();
    if (existing) {
      await ctx.db.patch(existing._id, preferences);
    } else {
      await ctx.db.insert("userPreferences", { userId: user._id, ...preferences });
    }
  },
});

export const getPreferences = query({
  args: { clerkId: v.string() },
  handler: async (ctx, { clerkId }) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", clerkId))
      .first();
    if (!user) return null;
    return ctx.db
      .query("userPreferences")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .first();
  },
});
