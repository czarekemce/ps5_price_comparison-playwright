import { test } from '@playwright/test';
import { BasePage } from '../pageObjects/basePage';
import { MediaExpert } from '../pageObjects/mediaPage';

test('Media expert - get PS5 lowest price', async ({ page }) => {
  const basePage = new BasePage(page);
  const media = new MediaExpert(page);

  await basePage.goto('https://www.mediaexpert.pl/gaming/playstation-5/konsole-ps5?');
  await basePage.acceptCookiesIfVisible(media.cookiesBanner, media.closeCookiesBannerButton);
  await basePage.sortByPrice(media.sortDropdownButton, media.lowestPriceButton);
  await media.removeAdvert();
  const mediaPrice = await basePage.getLowestPrice(media.itemPrice);
  await basePage.appendPriceToFile(mediaPrice, 'Media expert');
});

