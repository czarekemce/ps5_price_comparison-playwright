import { test } from '@playwright/test';
import { BasePage } from '../pageObjects/basePage';
import { EuroRtvAgd } from '../pageObjects/euroPage';

test('Euro rtv agd - get PS5 lowest price', async ({ page }) => {
  const basePage = new BasePage(page);
  const euro = new EuroRtvAgd(page);

  await basePage.goto('https://www.euro.com.pl/konsole-playstation-5.bhtml');
  await basePage.acceptCookiesIfVisible(euro.cookiesBanner, euro.acceptCookiesButton);
  await basePage.sortByPrice(euro.sortDropdownButton, euro.lowestPriceButton);
  const euroPrice = await basePage.getLowestPrice(euro.itemPrice);
  await basePage.appendPriceToFile(euroPrice, 'euro.com');
});