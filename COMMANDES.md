# Commandes utiles

## 1. Lancer UN test précis (recommandé) — depuis Git Bash

```bash
./scripts/run-tests.sh <nom-du-test>
```

(ou `bash scripts/run-tests.sh <nom-du-test>` si le fichier n'est pas
exécutable sur ta machine)

**⚠️ À exécuter depuis un terminal Git Bash**, pas depuis PowerShell/cmd :
sur Windows, la commande `bash` toute seule peut tomber sur le sous-système
Linux (WSL) au lieu de Git Bash selon la machine, et ça casse le script.
Ouvre Git Bash (clic droit dans le dossier → "Git Bash Here"), ou utilise
le terminal déjà ouvert si tu en as un.

Ce script lance **un seul fichier de test**, jamais toute la suite d'un
coup. `<nom-du-test>` accepte un nom partiel (`login`), un nom de fichier
(`login.spec.ts`) ou un chemin complet (`specs/login.spec.ts`).

```bash
./scripts/run-tests.sh login
./scripts/run-tests.sh specs/cart.spec.ts
```

Aide complète (liste aussi les specs disponibles) :

```bash
./scripts/run-tests.sh --help
```

Avant de lancer le test, le script vérifie automatiquement, étape par
étape et en couleur :

1. les variables d'environnement `ANDROID_HOME` et `JAVA_HOME`
2. que `node_modules` est installé
3. que `adb` et `appium` sont accessibles en ligne de commande
4. que le driver Appium `uiautomator2` est installé
5. que l'APK de l'app (`APK/my-demo-app-android.apk`) est présent
6. que le port Appium (4723) est libre (sinon il t'avertit d'un conflit
   possible, par ex. avec Appium Inspector déjà ouvert)
7. qu'un émulateur/appareil Android est connecté — **sinon il démarre
   l'émulateur `Phone` tout seul et attend qu'il soit prêt**

S'il manque quelque chose, le script s'arrête avec un message explicite
(ex: `node_modules manquant. Lance "npm install"`). À la fin, une bannière
verte "TEST RÉUSSI" ou rouge "TEST ÉCHOUÉ" s'affiche selon le résultat.

## 2. Lancer les tests sans les vérifications (plus rapide, moins sûr)

```bash
npm test
```

ou

```bash
npm run wdio
```

Exécute directement `wdio run ./wdio.conf.ts`, sans aucune
vérification préalable. Utile si tu sais que l'environnement est déjà prêt
(ex: tu viens de lancer `./scripts/run-tests.sh` avec succès et tu relances
juste les tests).

## 3. Démarrer l'émulateur manuellement

Pas obligatoire (`run-tests.sh` le fait automatiquement si besoin), mais
utile si tu veux le garder ouvert pendant que tu utilises Appium
Inspector :

```bash
emulator -avd Phone
```

Vérifier qu'il est bien démarré :

```bash
adb devices
```

## 4. Lancer un seul fichier de test directement avec wdio

```bash
npx wdio run ./wdio.conf.ts --spec specs/login.spec.ts
```

(remplace le chemin par le spec que tu veux déboguer)

## 5. Vérifier que l'environnement est sain

À lancer si un test échoue de façon suspecte, pour éliminer une cause
d'environnement :

```bash
appium-doctor --android
```

## 6. Appium Inspector (relever les locators)

Appli graphique (menu Démarrer → "Appium Inspector"), pas une commande.
Remote server : `127.0.0.1:4723`. Capabilities à utiliser :

```json
{
  "platformName": "Android",
  "appium:deviceName": "Phone",
  "appium:avd": "Phone",
  "appium:automationName": "UiAutomator2",
  "appium:app": "D:/Projets/Test/appium-mobile-tests/APK/my-demo-app-android.apk"
}
```

**Important** : si tu utilises Appium Inspector en même temps que `npm run wdio`,
lance d'abord un serveur Appium à part :

```bash
appium
```

car `npm run wdio` démarre et arrête son propre serveur Appium à chaque run.
