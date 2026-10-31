#!/usr/bin/env bash
#
# Pré-vol avant de lancer UN test Appium précis (à exécuter depuis Git Bash) :
#   Étape 1 — variables d'environnement (ANDROID_HOME, JAVA_HOME)
#   Étape 2 — dépendances npm installées
#   Étape 3 — outils en ligne de commande (adb, appium)
#   Étape 4 — driver Appium uiautomator2 installé
#   Étape 5 — APK de l'app présent
#   Étape 6 — port Appium (4723) libre
#   Étape 7 — émulateur/appareil Android connecté (sinon démarrage auto de l'AVD)
# Puis lance ce SEUL test avec `wdio run ./wdio.conf.ts --spec ...`.
#
# Usage : ./scripts/run-tests.sh -h

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

APK_PATH="$ROOT_DIR/APK/my-demo-app-android.apk"
AVD_NAME="Phone"
APPIUM_PORT=4723
BOOT_TIMEOUT=120 # secondes
TOTAL_STEPS=7

# --- Couleurs -----------------------------------------------------------
# quoting ANSI-C ($'...') : les variables contiennent le vrai octet ESC,
# donc ça marche aussi bien avec `echo -e` qu'avec `cat` (heredoc de l'aide)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

OK="${GREEN}✔${RESET}"
KO="${RED}✖${RESET}"
WARN="${YELLOW}⚠${RESET}"

# --- Fonctions utilitaires ---------------------------------------------

die() {
    echo -e "\n${KO} ${RED}$1${RESET}" >&2
    exit 1
}

step_header() {
    echo -e "\n${BOLD}${CYAN}── Étape $1/${TOTAL_STEPS} : $2${RESET}"
}

list_specs() {
    local found
    found="$(find "$ROOT_DIR/specs" -type f -name '*.ts' 2>/dev/null | sed "s#^$ROOT_DIR/##")"
    if [ -z "$found" ]; then
        echo "  (aucun spec pour l'instant — écris ton premier test dans specs/, voir \"TA MOBILE.md\")"
    else
        echo "$found" | sed 's/^/  - /'
    fi
}

show_help() {
    cat <<EOF
${BOLD}Usage${RESET} : ./scripts/run-tests.sh [-h|--help] <nom-du-test> [options wdio...]

Vérifie que l'environnement Appium est prêt (7 étapes), puis lance UN SEUL
fichier de test — jamais toute la suite d'un coup.

${BOLD}Arguments${RESET}
  <nom-du-test>   Nom ou chemin du spec à lancer. Accepte :
                    - un nom partiel      : login
                    - un nom de fichier    : login.spec.ts
                    - un chemin complet    : specs/login.spec.ts

${BOLD}Options${RESET}
  -h, --help      Affiche cette aide et quitte (aucune vérification lancée)

Tout argument supplémentaire après le nom du test est transmis tel quel
à "wdio run" (ex: --mochaOpts.grep "connexion").

${BOLD}Exemples${RESET}
  ./scripts/run-tests.sh login
  ./scripts/run-tests.sh specs/cart.spec.ts
  ./scripts/run-tests.sh login --mochaOpts.grep "connexion"

${BOLD}Specs disponibles${RESET}
$(list_specs)
EOF
}

# Résout un nom/chemin de test vers un chemin de spec réel.
# Écrit le chemin trouvé sur stdout. Code retour : 0 trouvé, 1 introuvable,
# 2 ambigu (plusieurs correspondances, listées sur stderr).
resolve_spec() {
    local query="$1"

    if [ -f "$ROOT_DIR/$query" ]; then
        printf '%s\n' "$query"
        return 0
    fi
    if [ -f "$ROOT_DIR/specs/$query" ]; then
        printf '%s\n' "specs/$query"
        return 0
    fi

    local -a matches=()
    while IFS= read -r -d '' f; do
        matches+=("${f#$ROOT_DIR/}")
    done < <(find "$ROOT_DIR/specs" -type f -iname "*${query}*" -print0 2>/dev/null)

    if [ "${#matches[@]}" -eq 1 ]; then
        printf '%s\n' "${matches[0]}"
        return 0
    elif [ "${#matches[@]}" -gt 1 ]; then
        echo "Plusieurs specs correspondent à \"$query\" :" >&2
        printf '   - %s\n' "${matches[@]}" >&2
        return 2
    else
        return 1
    fi
}

print_success_banner() {
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════╗"
    echo "  ║                                  ║"
    echo "  ║          TEST RÉUSSI             ║"
    echo "  ║                                  ║"
    echo "  ╚══════════════════════════════════╝"
    echo -e "${RESET}"
}

print_failure_banner() {
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════╗"
    echo "  ║                                  ║"
    echo "  ║          TEST ÉCHOUÉ             ║"
    echo "  ║                                  ║"
    echo "  ╚══════════════════════════════════╝"
    echo -e "${RESET}"
}

# --- Analyse des arguments ---------------------------------------------

POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            POSITIONAL+=("$arg")
            ;;
    esac
done

TEST_NAME="${POSITIONAL[0]:-}"
if [ -z "$TEST_NAME" ]; then
    echo -e "${KO} ${RED}Indique le test à lancer, ex: ./scripts/run-tests.sh login${RESET}" >&2
    echo "" >&2
    echo "Specs disponibles :" >&2
    list_specs >&2
    echo "" >&2
    echo "Lance avec -h ou --help pour voir l'aide complète." >&2
    exit 1
fi
EXTRA_ARGS=("${POSITIONAL[@]:1}")

SPEC_PATH="$(resolve_spec "$TEST_NAME")"
resolve_rc=$?
if [ "$resolve_rc" -eq 1 ]; then
    die "Aucun spec ne correspond à \"$TEST_NAME\" dans specs/.\n$(list_specs)"
elif [ "$resolve_rc" -eq 2 ]; then
    die "Précise le chemin complet (plusieurs specs correspondent à \"$TEST_NAME\", voir ci-dessus)."
fi

echo -e "${BOLD}=== Vérification de l'environnement avant de lancer : ${SPEC_PATH} ===${RESET}"

# --- Étape 1 : variables d'environnement --------------------------------
step_header 1 "Variables d'environnement"
for var in ANDROID_HOME JAVA_HOME; do
    value="${!var:-}"
    if [ -n "$value" ] && [ -d "$value" ]; then
        echo -e "   ${OK} $var = $value"
    else
        die "$var n'est pas défini (ou le dossier n'existe pas). Voir \"TA MOBILE.md\", section 1."
    fi
done

# --- Étape 2 : dépendances npm ------------------------------------------
step_header 2 "Dépendances du projet"
if [ -f "$ROOT_DIR/node_modules/.bin/wdio" ] || [ -f "$ROOT_DIR/node_modules/.bin/wdio.cmd" ]; then
    echo -e "   ${OK} node_modules présent"
else
    die 'node_modules manquant. Lance "npm install" avant de relancer ce script.'
fi

# --- Étape 3 : outils en ligne de commande (adb, appium) ----------------
step_header 3 "Outils en ligne de commande"
if command -v adb >/dev/null 2>&1; then
    echo -e "   ${OK} adb trouvé"
else
    die 'adb introuvable. Vérifie que %ANDROID_HOME%\platform-tools est dans le PATH.'
fi

if command -v appium >/dev/null 2>&1; then
    appium_version="$(appium -v 2>&1)"
    echo -e "   ${OK} appium trouvé (v${appium_version})"
else
    die 'La commande "appium" est introuvable. Installe-la avec "npm install -g appium".'
fi

# --- Étape 4 : driver Appium ---------------------------------------------
step_header 4 "Driver Appium (uiautomator2)"
if appium driver list --installed 2>&1 | grep -q uiautomator2; then
    echo -e "   ${OK} driver uiautomator2 installé"
else
    die 'Le driver uiautomator2 n'"'"'est pas installé. Lance "appium driver install uiautomator2".'
fi

# --- Étape 5 : APK présent ------------------------------------------------
step_header 5 "Application à tester"
if [ -f "$APK_PATH" ]; then
    echo -e "   ${OK} APK trouvé : APK/my-demo-app-android.apk"
else
    die "APK introuvable ($APK_PATH). Télécharge-le depuis https://github.com/saucelabs/my-demo-app-android/releases et place-le dans APK/my-demo-app-android.apk"
fi

# --- Étape 6 : port Appium libre ------------------------------------------
step_header 6 "Port Appium (${APPIUM_PORT})"
port_busy=""
if command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "$APPIUM_PORT" >/dev/null 2>&1 && port_busy="1"
else
    (exec 3<>"/dev/tcp/127.0.0.1/${APPIUM_PORT}") 2>/dev/null && { port_busy="1"; exec 3<&- 3>&-; }
fi
if [ -n "$port_busy" ]; then
    echo -e "   ${WARN} le port ${APPIUM_PORT} est déjà occupé (un serveur Appium tourne peut-être déjà, ex: Appium Inspector)."
    echo -e "   ${WARN} le service wdio va essayer de démarrer SON propre serveur sur ce port : ferme l'autre serveur si le test plante à cause de ça."
else
    echo -e "   ${OK} port ${APPIUM_PORT} libre"
fi

# --- Étape 7 : émulateur / appareil Android connecté -----------------------
step_header 7 "Émulateur / appareil Android"
device="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
if [ -n "$device" ]; then
    echo -e "   ${OK} émulateur déjà démarré et connecté : $device"
else
    echo -e "   ${WARN} aucun émulateur connecté, démarrage de l'AVD \"$AVD_NAME\"..."
    if ! emulator -list-avds | grep -qx "$AVD_NAME"; then
        die "Aucun AVD nommé \"$AVD_NAME\" trouvé. Crée-le dans Android Studio (Device Manager) ou change AVD_NAME dans ce script."
    fi

    nohup emulator -avd "$AVD_NAME" -no-snapshot-load >/dev/null 2>&1 &

    echo -n "   démarrage en cours (peut prendre 1 à 2 minutes) "
    elapsed=0
    booted=""
    while [ "$elapsed" -lt "$BOOT_TIMEOUT" ]; do
        boot_status="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
        if [ "$boot_status" = "1" ]; then
            booted="1"
            break
        fi
        echo -n "."
        sleep 3
        elapsed=$((elapsed + 3))
    done

    if [ -z "$booted" ]; then
        die "Timeout en attendant le démarrage de l'émulateur."
    fi

    device="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')"
    if [ -z "$device" ]; then
        die "L'émulateur a démarré mais adb ne le voit pas comme connecté."
    fi
    echo -e "\n   ${OK} émulateur démarré et connecté : $device"
fi

# --- Lancement du test ------------------------------------------------------
echo -e "\n${BOLD}=== Lancement de ${SPEC_PATH} ===${RESET}\n"
npx wdio run ./wdio.conf.ts --spec "$SPEC_PATH" "${EXTRA_ARGS[@]}"
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
    print_success_banner
else
    print_failure_banner
fi

exit "$exit_code"
