// Page = QUE des selectors. Écran "My Cart" (un fichier = un écran).

const PKG = 'com.saucelabs.mydemoapp.android';

export const CartPage = {
    productTitle: `android=new UiSelector().resourceId("${PKG}:id/titleTV")`,
    productQuantity: `android=new UiSelector().resourceId("${PKG}:id/noTV")`,
};
