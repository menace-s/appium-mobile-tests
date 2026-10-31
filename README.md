# appium-mobile-tests

Projet d'automatisation de tests mobiles Android. Stack : Appium 2 +
WebdriverIO + Mocha + TypeScript. Application testée : Sauce Labs "My Demo
App" (Android, open source).

Ce fichier décrit le projet tel qu'il existe aujourd'hui (architecture,
dossiers, état d'avancement). Le déroulé pédagogique complet (objectifs,
vocabulaire, plan sur 5 jours) est dans [TA MOBILE.md](TA%20MOBILE.md). Les
commandes pour lancer les tests sont dans [COMMANDES.md](COMMANDES.md).

## Stack

- Node.js
- Java JDK (requis par le SDK Android et Appium)
- Android SDK + émulateur (Android Studio)
- Appium 2 avec le driver UiAutomator2
- WebdriverIO + Mocha + TypeScript

## Architecture

```
appium-mobile-tests/
├── APK/                    app Android testée (.apk, non versionné)
├── _common/
│   └── types/              types partagés (ex: TestInfo)
├── config/                 réservé aux futurs fichiers de configuration
├── pages/                  selectors uniquement, un fichier par écran
├── flows/                  scénarios métier réutilisables (vide pour l'instant)
├── scripts/
│   └── run-tests.sh        script de lancement avec vérifications d'environnement
├── specs/                  un fichier = un cas de test (avec les expect())
├── support/
│   ├── fonction.ts         façade d'actions bas niveau réutilisables
│   └── logger.ts           logger console + cartouche d'info de test
├── wdio.conf.ts            configuration WebdriverIO / Appium
└── tsconfig.json
```

### Rôle de chaque couche (règle stricte)

| Dossier | Contient | Ne contient pas |
|---|---|---|
| `pages/` | Uniquement des selectors (objet simple) | Aucune action, aucune méthode, n'importe jamais `support/fonction.ts` |
| `support/fonction.ts` | La classe `Fonction` : actions bas niveau (`clickElement`, `waitAndClick`, `typeText`, `waitDisplayed`, `getText`) | Aucun selector en dur, aucune logique métier |
| `support/logger.ts` | Le logger console (`[INFO]`, `[STEP]`, `[WARN]`, `[ERROR]`, `[DEBUG]`) et l'affichage de la cartouche de test | Aucun appel au driver |
| `_common/types/` | Types partagés entre les couches (ex: `TestInfo`) | Aucune logique, aucune donnée d'exécution |
| `flows/` | Une classe qui crée une instance de `Fonction` et importe les selectors d'une page pour construire un scénario réutilisable (`run()`) | Aucun `expect()` |
| `specs/` | Un cas de test Mocha : instancie les pages/la façade, exécute les étapes, puis vérifie le résultat avec `expect()` | Aucun selector en dur, aucun appel direct au driver |

Les `pages/` ne parlent jamais à `Fonction`. C'est le **spec** (ou le futur
**flow**) qui fait le lien : il utilise les selectors d'une page et les
passe aux méthodes de `Fonction`.

### Cartouche de test

Chaque spec peut déclarer un objet `TestInfo` (`_common/types/test-info.ts`)
avec un id, une référence et un titre, puis l'afficher avant l'exécution
via `logger.testInfo(testInfo)` dans un hook `before()`. Ça permet
d'identifier immédiatement, dans les logs, quel cas de test est en train de
s'exécuter.

## Lancer les tests

Voir [COMMANDES.md](COMMANDES.md) pour le détail. En résumé, depuis un
terminal Git Bash :

```bash
./scripts/run-tests.sh <nom-du-test>
```

Ce script vérifie l'environnement (variables, outils, driver Appium, APK,
port, émulateur) avant de lancer le test demandé, puis affiche une bannière
de résultat.

## État d'avancement

- `specs/cart.spec.ts` : cas de test "Ajouter un produit au panier" —
  terminé, passe.
- Connexion (`pages/login.page.ts`, `flows/login.flow.ts`,
  `specs/login.spec.ts`) : pas encore fait.
- `flows/` : pas encore utilisé, réservé pour les scénarios métier
  réutilisables (ex: connexion).
- `config/` : vide, réservé aux futurs fichiers de configuration.
