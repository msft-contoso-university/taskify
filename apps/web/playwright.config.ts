import { test, expect } from "@playwright/test";

test("home page loads and shows Taskify header", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByText("Taskify")).toBeVisible();
});
