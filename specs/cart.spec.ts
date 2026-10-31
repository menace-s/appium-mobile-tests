// Cas de test 2 — Ajouter un produit au panier (voir "TA MOBILE.md", section 5)

import { ProductsPage }    from '../pages/products.page';
import { CartPage }        from '../pages/cart.page';
import { Fonction }        from '../support/fonction';
import { logger }          from '../support/logger';
import type { TestInfo }   from '../_common/types/test-info';


const testInfo  : TestInfo = {
    id          : 'TC-02',
    reference   : 'CART-ADD-001',
    title       : 'Ajouter un produit au panier',
    description : 'Le panier doit afficher le bon produit avec la bonne quantité',
};


describe('Panier', () => {
    const fonction = new Fonction();

    before(() => {
        logger.testInfo(testInfo);
    });

    it('ajoute un produit au panier avec la bonne quantité', async () => {
        // 1. cliquer sur le premier produit du catalogue
        await fonction.waitAndClick(ProductsPage.productImage, 'premier produit du catalogue', 0);

        // 2. vérifier le titre du produit affiché
        await expect($(ProductsPage.productTitle)).toHaveText('Sauce Labs Backpack');

        // 3. passer la quantité à 2
        await fonction.waitAndClick(ProductsPage.increaseQtyButton, 'bouton +');

        // 4. ajouter au panier
        await fonction.waitAndClick(ProductsPage.addToCartButton, 'bouton Add to cart');

        // 5. ouvrir le panier
        await fonction.waitAndClick(ProductsPage.cartIcon, 'icône panier');

        // Résultat attendu : le panier affiche "Sauce Labs Backpack" avec une quantité de 2
        await expect($(CartPage.productTitle)).toHaveText('Sauce Labs Backpack');
        await expect($(CartPage.productQuantity)).toHaveText('2');
    });
});
