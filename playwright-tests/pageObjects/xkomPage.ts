import { Page, Locator } from '@playwright/test';

export class Xkom {
    readonly page: Page;
    readonly sortDropdownButton: Locator;
    readonly lowestPriceButton: Locator;
    readonly cookiesBanner: Locator;
    readonly acceptCookiesButton: Locator;
    readonly filteredContener: Locator;
    readonly itemPrice: Locator;

    constructor(page: Page) {
        this.page = page
        this.sortDropdownButton = this.page. locator('div').filter({ hasText: /^SortowanieOd najpopularniejszych$/ }).getByRole('listbox')
        this.lowestPriceButton = this.page.getByRole('option').getByText('Cena: od najtańszych')
        this.cookiesBanner = this.page.getByRole('dialog')
        this.acceptCookiesButton = this.page.locator('[data-name="AcceptPermissionButton"]')
        this.filteredContener = this.page.locator('#listing-container > div > div[data-name="productCard"]')
        this.itemPrice = this.filteredContener.locator('[data-name="productPrice"]').first()
    };
}