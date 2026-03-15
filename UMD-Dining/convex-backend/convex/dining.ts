import { query } from "./_generated/server";

export const getDiningHalls = query({
  args: {},
  handler: async (ctx) => ctx.db.query("diningHalls").collect(),
});

export const getSections = query({
  args: {},
  handler: async (ctx) => ctx.db.query("sections").collect(),
});

export const getMealTypes = query({
  args: {},
  handler: async (ctx) => ctx.db.query("mealTypes").collect(),
});

export const getAvailableDates = query({
  args: {},
  handler: async (ctx) => ctx.db.query("dates").order("desc").take(14),
});
