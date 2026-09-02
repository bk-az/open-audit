#!/bin/sh

VERSION="6.0.4"
APP_NAME="AS Network Scanner"
INSTALL_DIR="/usr/local/as-network-scanner"
FALLBACK_INSTALL_DIR="/usr/local/open-audit"
WEB_ALIAS="as-network-scanner"
FALLBACK_WEB_ALIAS="open-audit"
WWWTARGETDIR="/var/www/html"

if [ "$(id -u)" != "0" ]; then
    echo "This uninstall script must be run as root."
    exit 1
fi

rm -rf "$WWWTARGETDIR/$WEB_ALIAS"
rm -rf "$WWWTARGETDIR/$FALLBACK_WEB_ALIAS"

if [ -L "$FALLBACK_INSTALL_DIR" ]; then
    rm -f "$FALLBACK_INSTALL_DIR"
fi

rm -rf "$INSTALL_DIR"

exit 0
