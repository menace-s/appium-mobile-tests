// Façade : actions bas niveau réutilisables, seule couche qui parle au
// driver (voir "TA MOBILE.md", section 3). Les pages/ fournissent les
// selectors, les specs/flows appellent ces méthodes — jamais $() /
// .click() directement ailleurs.

import { logger } from './logger';

export class Fonction {
    /**
     * Résout un selector vers un élément. Si plusieurs éléments correspondent
     * (ex: une liste de produits), passe `index` pour choisir lequel.
     */
    private element(selector: string, index?: number) {
        return index === undefined ? $(selector) : $$(selector)[index];
    }

    /** Attend qu'un élément soit affiché et le retourne. */
    async waitDisplayed(selector: string, label: string = selector, index?: number) {
        const el = await this.element(selector, index);
        await el.waitForDisplayed({ timeoutMsg: `"${label}" non affiché à temps` });
        return el;
    }

    /** Clique sur un élément déjà affiché (pas d'attente). */
    async clickElement(selector: string, label: string = selector, index?: number) {
        const el = await this.element(selector, index);
        logger.step(`Clic sur ${label}`);
        await el.click();
    }

    /** Attend qu'un élément soit affiché puis clique dessus. */
    async waitAndClick(selector: string, label: string = selector, index?: number) {
        await this.waitDisplayed(selector, label, index);
        await this.clickElement(selector, label, index);
    }

    /** Attend qu'un champ soit affiché puis y saisit du texte. */
    async typeText(selector: string, text: string, label: string = selector) {
        const el = await this.waitDisplayed(selector, label);
        logger.step(`Saisie dans ${label}`);
        await el.setValue(text);
    }

    /** Attend qu'un élément soit affiché puis lit son texte. */
    async getText(selector: string, label: string = selector, index?: number): Promise<string> {
        const el = await this.waitDisplayed(selector, label, index);
        const text = await el.getText();
        logger.debug(`Texte lu dans ${label} : "${text}"`);
        return text;
    }
}
