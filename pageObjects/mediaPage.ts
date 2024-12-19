import { expect, type Page, Locator } from '@playwright/test';

export class MediaExpert {
    readonly page: Page;
    readonly sortDropdownButton: Locator;
    readonly lowestPriceButton: Locator;
    readonly closeCookiesBannerButton: Locator;
    readonly cookiesBanner: Locator;
    readonly sectionListItems: Locator;
    readonly advertModal: Locator;
    readonly itemPrice: Locator;

    constructor(page: Page) {
        this.page = page
        this.sortDropdownButton = this.page.locator('span.multiselect__single').getByText('Popularność')
        this.lowestPriceButton = this.page.locator('ul > li').getByText('Cena - rosnąco')
        this.closeCookiesBannerButton = this.page.locator('#onetrust-accept-btn-handler')
        this.cookiesBanner = this.page.locator('[aria-label="Cookie banner"]')
        this.sectionListItems = this.page.locator('#section_list-items > div').first()
        this.advertModal = this.page.locator('div.contentmodal')
        this.itemPrice = this.sectionListItems.locator('div.prices').first()
    };

    async removeAdvert() {
        if (await this.advertModal.isVisible()) {
            await this.page.locator('#snrs-close').click()
            expect(this.advertModal).not.toBeVisible()
        };
    };
}