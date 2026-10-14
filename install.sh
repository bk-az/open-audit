#!/bin/sh

APP_NAME="AS Network Scanner"
VENDOR_NAME="AssetSonar"
VENDOR_URL="https://ezo.io/assetsonar/"
INSTALL_DIR="/usr/local/as-network-scanner"
FALLBACK_INSTALL_DIR="/usr/local/open-audit"
WEB_ALIAS="as-network-scanner"
FALLBACK_WEB_ALIAS="open-audit"
DB_NAME="openaudit"
DB_USER="openaudit"
DB_PASS="openauditpassword"
MYSQL_ROOT_DEFAULT_PASS="as_network_scanner_root"
UNATTENDED="n"
SKIP_DEPENDENCIES="n"
STAMP=$(date +%Y%m%d-%H%M%S)
VERSION=$(sed -n "s/.*define('APP_DISPLAY_VERSION', *'\\([^']*\\)').*/\\1/p" ./app/Config/Constants.php | head -n1)
RELEASE="$INSTALL_DIR/releases/$VERSION"
LOGFILE="$INSTALL_DIR/as-network-scanner-install-$STAMP.log"

if [ -z "$VERSION" ]; then
    echo "Could not read APP_DISPLAY_VERSION from app/Config/Constants.php" >&2
    exit 1
fi

# shellcheck source=installation_phases/helpers.sh
. ./installation_phases/helpers.sh

# install.sh lines 20-37, unchanged
if [ -n "$1" ]; then
    TEST="$1"
    if [ "$TEST" = "--skip-dependencies" ]; then
       SKIP_DEPENDENCIES="y"
    fi
    if [ "$TEST" = "--unattended" ]; then
        UNATTENDED="y"
    fi
fi
if [ -n "$2" ]; then
    TEST="$2"
    if [ "$TEST" = "--skip-dependencies" ]; then
       SKIP_DEPENDENCIES="y"
    fi
    if [ "$TEST" = "--unattended" ]; then
        UNATTENDED="y"
    fi
fi

PHASES=""
for ARG in "$@"; do
    case "$ARG" in
        dependencies|stage|qualify|commit)
            PHASES="$PHASES $ARG"
            ;;
    esac
done
if [ -z "$PHASES" ]; then
    PHASES="dependencies stage qualify commit"
fi

# Log is created here. Phases append to it. Nothing moves it afterwards.
mkdir -p "$INSTALL_DIR"
logmsg "Release version $VERSION"
printBanner "$APP_NAME v$VERSION installation script"
root_password=""
detect_running_release   # sets RUNNING_RELEASE_DIR; does not move a flat tree
detect_os                # sets OSFLAVOUR, OS_VERSION, OS_MAJOR/MINOR/PATCH, OS_ISCENTOS

status="install"
if [ -n "$RUNNING_RELEASE_DIR" ]; then
    status="upgrade"
fi
logmsg "Install status: $status"

for PHASE in $PHASES; do
    . ./installation_phases/$PHASE.sh
done
exit 0
