// Page = QUE des selectors (voir "TA MOBILE.md", section 3). Écran catalogue
// + écran détail produit. Locators confirmés via uiautomator dump sur l'app
// réelle (pas recopiés à l'aveugle depuis le README).

const PKG = 'com.saucelabs.mydemoapp.android';

export const ProductsPage = {
    menuIcon: '~View menu',
    cartIcon: '~View cart',
    productImage: '~Product Image',
    productTitle: `android=new UiSelector().resourceId("${PKG}:id/productTV")`,
    increaseQtyButton: '~Increase item quantity',
    addToCartButton: '~Tap to add product to cart',
};
