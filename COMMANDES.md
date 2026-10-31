# Commandes utiles

## 1. Démarrer l'émulateur Android

```bash
emulator -avd Phone
```

Laisse cette commande tourner dans un terminal pendant que tu travailles.
Vérifier qu'il est bien démarré :

```bash
adb devices
```

## 2. Lancer les tests

Depuis la racine du projet (deux scripts équivalents) :

```bash
npm run wdio
```

```bash
npm test
```

Les deux exécutent `wdio run ./config/wdio.conf.ts`. Le service Appium démarre
et s'arrête automatiquement : pas besoin de lancer `appium` toi-même.

## 3. Lancer un seul fichier de test

```bash
npx wdio run ./config/wdio.conf.ts --spec specs/login.spec.ts
```

(remplace le chemin par le spec que tu veux déboguer)

## 4. Vérifier que l'environnement est sain

À lancer si un test échoue de façon suspecte, pour éliminer une cause
d'environnement :

```bash
appium-doctor --android
```

## 5. Appium Inspector (relever les locators)

Appli graphique (menu Démarrer → "Appium Inspector"), pas une commande.
Remote server : `127.0.0.1:4723`. Capabilities à utiliser :

```json
{
  "platformName": "Android",
  "appium:deviceName": "Phone",
  "appium:avd": "Phone",
  "appium:automationName": "UiAutomator2",
  "appium:app": "D:/Projets/Test/appium-mobile-tests/apps/my-demo-app-android.apk"
}
```

**Important** : si tu utilises Appium Inspector en même temps que `npm run wdio`,
lance d'abord un serveur Appium à part :

```bash
appium
```

car `npm run wdio` démarre et arrête son propre serveur Appium à chaque run.
