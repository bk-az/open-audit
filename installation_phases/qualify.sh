printBanner "Qualify Phase starting"
# creds from the NEW release Database.json (stage already swapped in the previous file)
hostname=$(grep hostname "$RELEASE/app/Config/Database.json" | cut -d\" -f4)
username=$(grep username "$RELEASE/app/Config/Database.json" | cut -d\" -f4)
password=$(grep password "$RELEASE/app/Config/Database.json" | cut -d\" -f4)
database=$(grep database "$RELEASE/app/Config/Database.json" | cut -d\" -f4)

if [ -n "$RUNNING_RELEASE_DIR" ]; then
    logmsg "Backing up database to $RUNNING_RELEASE_DIR/${database}-backup-${STAMP}.sql."
    logmsg "mysqldump -u $username -pREMOVED -h $hostname $database > $RUNNING_RELEASE_DIR/${database}-backup-${STAMP}.sql"
    mysqldump -u "$username" -p"$password" -h "$hostname" "$database" \
        > "$RUNNING_RELEASE_DIR/${database}-backup-${STAMP}.sql"
    if [ "$?" -ne 0 ]; then
        logmsg "Could not back up $database. The credentials in $RELEASE/app/Config/Database.json were rejected. Exiting."
        exit 1
    fi
    logmsg "Upgrade of existing $APP_NAME installation, no database initialisation required."
else
    if [ "$(mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${database}' AND table_name='devices';")" = "1" ]; then
        logmsg "Table devices already exists in $database. Skipping user create and seed."
    else
        printBanner "$APP_NAME Database Setup"
        if ! mysql -u root -e 'exit' >/dev/null 2>&1; then
            if [ -z "$UNATTENDED" ]; then
                echo "We require the MySQL root user credentials to create the database and user."
                while true; do
                    input_text "Enter the MySQL root user's password:"
                    root_password="$RESPONSE"
                    if mysql -u root -e 'exit' >/dev/null 2>&1; then
                        break;
                    fi
                    echo "The MySQL root password is incorrect. Please re-enter it."
                done
            else
                logmsg "Unattended mode specified but MySQL root uses a password, exiting."
                logmsg "You will need to create the database and user manually."
                exit 1;
            fi
        fi

        if [ -z "$root_password" ] && [ -z "$UNATTENDED" ]; then
            logmsg "Your MySQL root password is blank."
            if input_yn "Should I set the default MySQL root password to '$MYSQL_ROOT_DEFAULT_PASS' (y/n)? "; then
                logmsg "Setting the MySQL root password to '$MYSQL_ROOT_DEFAULT_PASS'";
                root_password="$MYSQL_ROOT_DEFAULT_PASS"
                RES=0;
                unset OUTPUT;
                OUTPUT="$(mysql -u root -e "USE mysql; SET PASSWORD FOR 'root'@'localhost' = password('$root_password'); FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
                if [ "$RES" != 0 ]; then
                    logmsg "mysql -u root -e \"USE mysql; SET PASSWORD FOR 'root'@'localhost' = password('$root_password'); FLUSH PRIVILEGES;\" 2>&1" \
                        "${RES}" \
                        "${OUTPUT:-}";
                    RES=0;
                    unset OUTPUT;
                    OUTPUT="$(mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password'; FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
                    if [ "$RES" != 0 ]; then
                        logmsg "mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password'; FLUSH PRIVILEGES;\" 2>&1" \
                            "${RES}" \
                            "${OUTPUT:-}";
                        echo "WARNING - Could not set the password for the MySQL root user. You will have to do this manually."
                    fi
                fi
            else
                logmsg "Not updating the blank MySQL root password as instructed."
            fi
        fi

        printBanner "Creating the $APP_NAME database and MySQL user."

        RES=0;
        unset OUTPUT;
        if [ -n "$root_password" ]; then
            OUTPUT="$(mysql -u root -p$root_password -e "CREATE DATABASE $DB_NAME;" 2>&1)"||RES=$?;
            logmsg "CREATE DATABASE for $APP_NAME (exit ${RES})" \
            "${RES}" \
            "${OUTPUT:-}";
        else
            OUTPUT="$(mysql -u root -e "CREATE DATABASE $DB_NAME;" 2>&1)"||RES=$?;
            logmsg "CREATE DATABASE for $APP_NAME (exit ${RES})" \
            "${RES}" \
            "${OUTPUT:-}";
        fi

        if [ "$RES" != 0 ]; then
            printBanner "Database Warning"
            logmsg "WARNING - Could not create the database. You will have to do this manually."
            if input_yn "Type y to continue (y/n)? "; then
                logmsg "Continuing"
            else
                logmsg "Exiting"
                logmsg "Could not create the database. Aborting $status Process."
                logmsg "Release $RELEASE was staged but is not qualified. Live links were not changed."
                exit 1;
            fi
        fi

        RES=0;
        unset OUTPUT;
        if [ -n "$root_password" ]; then
            OUTPUT="$(mysql -u root -p$root_password -e "CREATE USER ${DB_USER}@localhost IDENTIFIED BY '${DB_PASS}';" 2>&1)"||RES=$?;
            logmsg "CREATE USER for $APP_NAME (exit ${RES})" \
                        "${RES}" \
                        "${OUTPUT:-}";
        else
            OUTPUT="$(mysql -u root -e "CREATE USER ${DB_USER}@localhost IDENTIFIED BY '${DB_PASS}';" 2>&1)"||RES=$?;
            logmsg "CREATE USER for $APP_NAME (exit ${RES})" \
                        "${RES}" \
                        "${OUTPUT:-}";
        fi
        if [ "$RES" != 0 ]; then
            logmsg "WARNING - Could not create the MySQL user. You will have to do this manually."
        fi

        RES=0;
        unset OUTPUT;
        if [ -n "$root_password" ]; then
            OUTPUT="$(mysql -u root -p$root_password -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost IDENTIFIED BY '${DB_PASS}'; FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
        else
            OUTPUT="$(mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost IDENTIFIED BY '${DB_PASS}'; FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
        fi
        if [ "$RES" != 0 ]; then
            if [ -n "$root_password" ]; then
                logmsg "GRANT privileges for $APP_NAME database user (exit ${RES})" \
                    "${RES}" \
                    "${OUTPUT:-}";
            else
                logmsg "GRANT privileges for $APP_NAME database user (exit ${RES})" \
                    "${RES}" \
                    "${OUTPUT:-}";
            fi
            RES=0;
            unset OUTPUT;
            if [ -n "$root_password" ]; then
                OUTPUT="$(mysql -u root -p$root_password -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost; FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
            else
                OUTPUT="$(mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost; FLUSH PRIVILEGES;" 2>&1)"||RES=$?;
            fi
            if [ "$RES" != 0 ]; then
                if [ -n "$root_password" ]; then
                    logmsg "GRANT privileges for $APP_NAME database user (exit ${RES})" \
                    "${RES}" \
                    "${OUTPUT:-}";
                else
                    logmsg "GRANT privileges for $APP_NAME database user (exit ${RES})" \
                    "${RES}" \
                    "${OUTPUT:-}";
                fi
                echo "WARNING - Could not grant access to the application MySQL user. You will have to do this manually."
            fi
        fi

        logmsg "Preparing the $APP_NAME database.";

        RES=0;
        unset OUTPUT;
        if [ -n "$root_password" ]; then
            OUTPUT="$(mysql -u root -p$root_password $DB_NAME -e "source $RELEASE/other/open-audit.sql" 2>&1)"||RES=$?;
        else
            OUTPUT="$(mysql -u root $DB_NAME -e "source $RELEASE/other/open-audit.sql" 2>&1)"||RES=$?;
        fi
        if [ -n "$root_password" ]; then
            logmsg "Load database schema for $APP_NAME (exit ${RES})" \
            "${RES}" \
            "${OUTPUT:-}";
        else
            logmsg "Load database schema for $APP_NAME (exit ${RES})" \
            "${RES}" \
            "${OUTPUT:-}";
        fi
        if [ "$RES" != 0 ]; then
            logmsg "WARNING - Could not populate the $APP_NAME database. You will need to do this manually."
        fi

        # Also check DB SEED, 
    fi
fi

php -S 127.0.0.1:8765 -t "$RELEASE/public" >>"$LOGFILE" 2>&1 &
PHP_SERVER_PID=$!
sleep 3
execPrint "curl -sf -o /dev/null -w '%{http_code}' 'http://127.0.0.1:8765/index.php/logon'"
LOGON_RES=$?
execPrint "kill $PHP_SERVER_PID"
wait "$PHP_SERVER_PID" 2>/dev/null
if [ "$LOGON_RES" != 0 ]; then
    logmsg "http://127.0.0.1:8765/index.php/logon did not return 200. Exiting."
    exit 1
fi

date -u +%Y-%m-%dT%H:%M:%SZ > "$RELEASE/qualified"
