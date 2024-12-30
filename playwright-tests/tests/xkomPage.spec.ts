import { test } from '@playwright/test';
import { BasePage } from '../pageObjects/basePage';
import { Xkom } from '../pageObjects/xkomPage';

test('X-Kom - get PS5 lowest price', async ({ page }) => {
  const basePage = new BasePage(page);
  const xkom = new Xkom(page);

  await basePage.goto('https://www.x-kom.pl/g-7/c/2572-konsole-playstation.html?');
  await basePage.acceptCookiesIfVisible(xkom.cookiesBanner, xkom.acceptCookiesButton);
  await basePage.sortByPrice(xkom.sortDropdownButton, xkom.lowestPriceButton);
  const xkomPrice = await basePage.getLowestPrice(xkom.itemPrice);
  await basePage.appendPriceToFile(xkomPrice, 'X-kom');
});