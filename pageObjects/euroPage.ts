import { Page, Locator } from '@playwright/test';

export class EuroRtvAgd {
    readonly page: Page;
    readonly sortDropdownButton: Locator;
    readonly lowestPriceButton: Locator;
    readonly cookiesBanner: Locator;
    readonly acceptCookiesButton: Locator;
    readonly itemPrice: Locator;

    constructor(page: Page) {
        this.page = page
        this.sortDropdownButton = this.page.locator('[aria-label="Suffix pola tekstowego"]').first()
        this.lowestPriceButton = this.page.locator('[role="listbox"] > [role="option"]').getByText('Od najtańszego')
        this.cookiesBanner = this.page.locator('[aria-label="Cookie banner"]')
        this.acceptCookiesButton = this.page.locator('#onetrust-accept-btn-handler')
        this.itemPrice = this.page.locator('span.parted-price-total').first()
    };
}