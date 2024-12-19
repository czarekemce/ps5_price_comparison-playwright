import { expect, type Page, Locator } from '@playwright/test';
const fs = require('fs/promises');


export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async goto(url: string) {
    await this.page.goto(url);
    await this.page.waitForLoadState('domcontentloaded')
  }

  async acceptCookiesIfVisible(banner: Locator, acceptButton: Locator) {
    const bannerHandle = await banner.elementHandle();
    if (bannerHandle) {
      await acceptButton.click({ force: true });
      await expect(banner).not.toBeVisible();
    }
  }

  async sortByPrice(listLocator: Locator, lowestPriceLocator: Locator) {
    await listLocator.scrollIntoViewIfNeeded()
    await listLocator.waitFor()
    await listLocator.click()
    await lowestPriceLocator.click()
  }

  async getLowestPrice(priceLocator) {
    await this.page.waitForLoadState('domcontentloaded')
    return priceLocator.textContent()
  }

  async appendPriceToFile(method) {
    const fileHandle = await fs.open('prices.txt', 'a');
    try {
        await fileHandle.write(method + '\n');
        const content = await fs.readFile('prices.txt', 'utf-8');
        console.log(content);
        
    } finally {
        await fileHandle.close();
    }
  }

}