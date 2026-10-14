# stage.sh. Logs the install.sh credential hints and exits.
# The tree was not moved, so there is no restore mv.
# The log is already under $INSTALL_DIR, so this does not move it.
unreadable_database_credentials() {
    logmsg "Upgrade detected, but cannot read database credentials. Aborting $status Process."
    if [ -f "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" ]; then
        logmsg "Database credentials should be readable in the file $RUNNING_RELEASE_DIR/code_igniter/application/config/database.php"
        logmsg "To check, run the below command:"
        logmsg "grep \"db\['default'\]\['username'\]\" \"$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php\" | head -n1 | cut -d\\\" -f2"
    fi
    if [ -f "$RUNNING_RELEASE_DIR/app/Config/Database.json" ]; then
        logmsg "Database credentials should be readable in the file $RUNNING_RELEASE_DIR/app/Config/Database.json"
        logmsg "To check, run the below command:"
        logmsg "grep username \"$RUNNING_RELEASE_DIR/app/Config/Database.json\" | head -n1 | cut -d\\\" -f2"
    fi
    exit 1
}

# install.sh lines 627-630. Reads database.php on $RUNNING_RELEASE_DIR.
# /bin/sh has no method-local variables unless the name is marked local.
# hostname, username, password, and database stay set for the caller.
fetch_pre5_credentials() {
    hostname=$(grep "db\['default'\]\['hostname'\]" "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" | head -n1 | cut -d\" -f2)
    username=$(grep "db\['default'\]\['username'\]" "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" | head -n1 | cut -d\" -f2)
    password=$(grep "db\['default'\]\['password'\]" "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" | head -n1 | cut -d\" -f2)
    database=$(grep "db\['default'\]\['database'\]" "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" | head -n1 | cut -d\" -f2)
}

# install.sh lines 634-637. Reads Database.json on $RUNNING_RELEASE_DIR.
fetch_post5_credentials() {
    hostname=$(grep hostname "$RUNNING_RELEASE_DIR/app/Config/Database.json" 2>/dev/null | cut -d\" -f4)
    username=$(grep username "$RUNNING_RELEASE_DIR/app/Config/Database.json" 2>/dev/null | cut -d\" -f4)
    password=$(grep password "$RUNNING_RELEASE_DIR/app/Config/Database.json" 2>/dev/null | cut -d\" -f4)
    database=$(grep database "$RUNNING_RELEASE_DIR/app/Config/Database.json" 2>/dev/null | cut -d\" -f4)
}

# install.sh lines 714-717. Writes the fetched values into the new release Database.json.
write_pre5_credentials() {
    sed -i -e "s|\"hostname\": \"127.0.0.1\"|\"hostname\": \"$hostname\"|" "$RELEASE/app/Config/Database.json"
    sed -i -e "s|\"database\": \"openaudit\"|\"database\": \"$database\"|" "$RELEASE/app/Config/Database.json"
    sed -i -e "s|\"username\": \"openaudit\"|\"username\": \"$username\"|" "$RELEASE/app/Config/Database.json"
    sed -i -e "s|\"password\": \"openauditpassword\"|\"password\": \"$password\"|" "$RELEASE/app/Config/Database.json"
}

printBanner "Stage Phase starting"

if [ "$(readlink -f . 2>/dev/null)" = "$(readlink -f "$INSTALL_DIR" 2>/dev/null)" ]; then
    logmsg "Refusing to stage from $INSTALL_DIR. That would copy releases/ into itself."
    exit 1
fi

if [ -d "$RELEASE" ] && [ "$(readlink -f "$INSTALL_DIR/current" 2>/dev/null)" = "$(readlink -f "$RELEASE")" ]; then
    logmsg "Release $VERSION is already current. Refusing to restage it."
    exit 1
fi

# install.sh lines 623-654. The previous tree was not moved, so it is still
# $RUNNING_RELEASE_DIR. Do not mv it onto $INSTALL_DIR or $RELEASE.
if [ -n "$RUNNING_RELEASE_DIR" ]; then
    status_existing="new"
    if [ -f "$RUNNING_RELEASE_DIR/code_igniter/application/config/database.php" ]; then
        logmsg "Upgrading pre v5.0.0."
        status_existing="old"
        fetch_pre5_credentials
    fi
    if [ "$status_existing" = "new" ]; then
        logmsg "Upgrading post 5.0.0"
        fetch_post5_credentials
    fi
    if [ -z "$hostname" ] || [ -z "$username" ] || [ -z "$password" ] || [ -z "$database" ]; then
        unreadable_database_credentials
    fi
fi

rm -rf "$RELEASE"
if ! execPrint "mkdir -p $RELEASE"; then
    logmsg "Cannot create $RELEASE. Aborting $status Process."
    exit 1
fi

printBanner "Installing $APP_NAME files"
execPrint "cp -far ./* $RELEASE"

# permissions
logmsg "Setting permissions on application configuration."
execNoPrint "chmod 0660 $RELEASE/app/Config/OpenAudit.php"
execPrint "chmod 0777 $RELEASE/other/scripts"
execPrint "chmod 0777 $RELEASE/other/ssg-results"
execPrint "chmod 0777 $RELEASE/public/ssg-definitions"
execPrint "chmod -R 777 $RELEASE/app/Attachments"
execPrint "chmod -R 777 $RELEASE/public/custom_images"
execPrint "chmod 0440 $RELEASE/app/Config/*.php"
execPrint "mkdir $RELEASE/writable/tmp"
execPrint "chmod -R 777 $RELEASE/writable"
execPrint "chmod 0666 $RELEASE/app/Views/lang/*.php"
execPrint "chmod -R 777 $RELEASE/public/aws_icons"
execPrint "chmod -R 777 $RELEASE/public/azure_icons"
execPrint "chmod 0777 $RELEASE/other/*.sh"
execPrint "chmod 0777 $RELEASE/other/winexe-static*"
execPrint "chmod 0777 $RELEASE/other/generate_auth_token.pl"
execPrint "chmod 0777 $RELEASE/other/enterprise.bin"

if [ -n "$RUNNING_RELEASE_DIR" ]; then
    if [ "$status_existing" = "old" ]; then
        logmsg "Copying pre-5.0.0 attachments and custom images."
        execPrint cp $RUNNING_RELEASE_DIR/code_igniter/application/attachments/* $RELEASE/app/Attachments/
        execPrint cp $RUNNING_RELEASE_DIR/www/open-audit/custom_images/* $RELEASE/public/custom_images/
        logmsg "Creating database credentials file."
        write_pre5_credentials
    fi
    if [ "$status_existing" = "new" ]; then
        logmsg "Copying attachments and custom images."
        execPrint cp $RUNNING_RELEASE_DIR/app/Attachments/* $RELEASE/app/Attachments/
        execPrint cp $RUNNING_RELEASE_DIR/public/custom_images/* $RELEASE/public/custom_images/
        logmsg "Restoring database credentials file."
        execPrint cp $RUNNING_RELEASE_DIR/app/Config/Database.json $RELEASE/app/Config/Database.json
    fi
fi
rm -f "$RELEASE/qualified"
