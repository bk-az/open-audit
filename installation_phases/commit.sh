printBanner "Commit Phase starting"
[ -f "$RELEASE/qualified" ] || { logmsg "Release $VERSION is not qualified."; exit 1; }

if [ "$OSFLAVOUR" = "redhat" ]; then
    WWWGRP="apache"
elif [ "$OSFLAVOUR" = "debian" ] || [ "$OSFLAVOUR" = "ubuntu" ]; then
    WWWGRP="www-data"
fi
WWWTARGETDIR=/var/www
[ -d "/var/www/html" ] && WWWTARGETDIR=/var/www/html
execPrint "chown -R $WWWGRP:$WWWGRP $INSTALL_DIR"

if [ -d "/var/www/html/as-network-scanner" ] && [ ! -L "/var/www/html/as-network-scanner" ]; then
    execPrint "mv /var/www/html/as-network-scanner /var/www/html/as-network-scanner.old.$STAMP"
    logmsg "Moving /var/www/html/as-network-scanner to /var/www/html/as-network-scanner.old.$STAMP"
fi
if [ -d "/var/www/as-network-scanner" ] && [ ! -L "/var/www/as-network-scanner" ]; then
    execPrint "mv /var/www/as-network-scanner /var/www/as-network-scanner.old"
    logmsg "Moving /var/www/as-network-scanner to /var/www/as-network-scanner.old"
fi

logmsg "Creating compatibility install symlink for $APP_NAME."
if [ -d "$FALLBACK_INSTALL_DIR" ] && [ ! -L "$FALLBACK_INSTALL_DIR" ]; then
    logmsg "Relocating previous legacy install directory (timestamped backup)."
    execNoPrint "mv $FALLBACK_INSTALL_DIR ${FALLBACK_INSTALL_DIR}.old.$STAMP"
fi

ln -sfn "$RELEASE" "$INSTALL_DIR/current"
ln -sfn "$INSTALL_DIR/current" "$FALLBACK_INSTALL_DIR"
ln -sfn "$INSTALL_DIR/current/public" "$WWWTARGETDIR/$WEB_ALIAS"
ln -sfn "$INSTALL_DIR/current/public" "$WWWTARGETDIR/$FALLBACK_WEB_ALIAS"
chown -h "$WWWGRP:$WWWGRP" "$WWWTARGETDIR/$WEB_ALIAS" "$WWWTARGETDIR/$FALLBACK_WEB_ALIAS"

# Only replace the default index.html if it's the boring 'it works' debian placeholder
if [ "$OSFLAVOUR" = "debian" ] || [ "$OSFLAVOUR" = "ubuntu" ] && grep -q "It works" $WWWTARGETDIR/index.html 2>/dev/null; then
    mv -f $WWWTARGETDIR/index.html $WWWTARGETDIR/index.html.boilerplate;
    cp $RELEASE/public/index.html.default $WWWTARGETDIR/index.html
fi

if [ "$status" = "install" ]; then
		printBanner "$APP_NAME has been installed"

		logmsg "This initial installation of $APP_NAME is now complete.

However, to configure and fine-tune the application suitably for
your environment you will need to make certain configuration adjustments.

Documentation: $VENDOR_URL

which will help you to determine any configuration changes
that may be required for your environment."

else
	printBanner "$APP_NAME has been upgraded"

    logmsg "Your $APP_NAME installation has now been upgraded.

You will find more information in the release notes at

$VENDOR_URL"

fi

printBanner "All Done!"

logmsg "$APP_NAME should now be accessible at

http://<HOSTNAME_OR_IP>/$WEB_ALIAS/index.php

Check your firewall(s).

$APP_NAME will require network connectivity to devices to collect data
as well as users connecting to the server to access the WEB GUI.

Please check any locally running firewall logs as well as network firewalls
if you are having any issues with connectivity.

You may also want to SHIFT+reload your browser page to make sure it retrieves the latest CSS and JS files.

We hope you find $APP_NAME useful."

SELINUX_STATUS=$(getenforce 2>/dev/null)
HTTPD_T_STATUS=$(semanage permissive -l 2>/dev/null | grep httpd_t)
if [ "$SELINUX_STATUS" = "Enforcing" ] && [ -z "$HTTPD_T_STATUS" ]; then
    logmsg "And one more thing: SELINUX IS ENFORCING with NO Apache exception."
    logmsg "Don't forget to disable SELinux or allow an exception for Apache."
fi
