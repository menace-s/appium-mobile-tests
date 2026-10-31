export const config: WebdriverIO.Config = {
    runner: 'local',
    tsConfigPath: '../tsconfig.json',

    port: 4723,

    // Specs: 1 fichier = 1 cas de test (voir TA MOBILE.md, section 2)
    specs: [
        '../specs/**/*.ts'
    ],
    exclude: [],

    maxInstances: 1,

    // Capabilities pour l'app native "My Demo App" (Sauce Labs) sur émulateur Android
    // -> télécharger l'APK ici : https://github.com/saucelabs/my-demo-app-android/releases
    //    et le placer dans ./apps/my-demo-app-android.apk
    capabilities: [{
        platformName: 'Android',
        'appium:deviceName': 'Phone', // nom de l'AVD créé dans Android Studio
        'appium:avd': 'Phone',
        'appium:automationName': 'UiAutomator2',
        'appium:app': require('path').join(process.cwd(), 'apps', 'my-demo-app-android.apk'),
        'appium:appWaitActivity': '*',
        'appium:avdLaunchTimeout': 120000,
        'appium:avdReadyTimeout': 120000
    }],

    logLevel: 'info',
    bail: 0,
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,

    services: ['appium'],
    framework: 'mocha',

    reporters: ['spec'],

    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    }
}
