printBanner "Dependencies Phase starting"

if [ "$OSFLAVOUR" = "redhat" ] && [ "$SKIP_DEPENDENCIES" = "n" ]; then
    printBanner "Package Cache"
    logmsg "Please ensure your existing operating system is patched and up to date."
    logmsg "You must have run 'yum update' and been successful in order to install $APP_NAME."
    if [ -n "$UNATTENDED" ] || input_yn "Have you successfully run yum update (y/n)? "; then
        logmsg "Continuing install."
    else
        logmsg "Please re-run this installer once yum update has successfully completed."
        exit 1;
    fi
fi


if [ "$OSFLAVOUR" = "redhat" ]; then
    if [ "$OS_MAJOR" -lt 9 ] ; then
        printBanner "Supported OS Warning"
        logmsg "The minimum supported version of Redhat (and related distro's) for $APP_NAME is 9, please upgrade your OS before attempting to install $APP_NAME."
        logmsg "The installer detected $OSFLAVOUR version $OS_MAJOR."
        if [ -n "$UNATTENDED" ]; then
            exit 1;
        fi
        if ! input_yn "Should I install anyway (y/n)? "; then
            exit 1;
        fi
    fi
fi

if [ "$OSFLAVOUR" = "debian" ]; then
    if [ "$OS_MAJOR" -lt 12 ] ; then
        printBanner "Supported OS Warning"
        logmsg "The minimum supported version of Debian for $APP_NAME is 12, please upgrade your OS before attempting to install $APP_NAME."
        logmsg "The installer detected $OSFLAVOUR version $OS_MAJOR."
        if [ -n "$UNATTENDED" ]; then
            exit 1;
        fi
        if ! input_yn "Should I install anyway (y/n)? "; then
            exit 1;
        fi
    fi
fi

if [ "$OSFLAVOUR" = "ubuntu" ]; then
    if [ "$OS_MAJOR" -lt 22 ] ; then
        printBanner "Supported OS Warning"
        logmsg "The minimum supported version of Ubuntu for $APP_NAME is 22, please upgrade your OS before attempting to install $APP_NAME."
        logmsg "The installer detected $OSFLAVOUR version $OS_MAJOR."
        if [ -n "$UNATTENDED" ]; then
            exit 1;
        fi
        if ! input_yn "Should I install anyway (y/n)? "; then
            exit 1;
        fi
    fi
fi

if [ "$OSFLAVOUR" != "ubuntu" ] && [ "$OSFLAVOUR" != "debian" ] && [ "$OSFLAVOUR" != "redhat" ]; then
    printBanner "Supported OS Warning"
    logmsg "The supported distributions are Redhat, Debian and Ubuntu."
    logmsg "The installer detected $OSFLAVOUR version $OS_MAJOR."
    if [ -n "$UNATTENDED" ]; then
        exit 1;
    fi
    if ! input_yn "Should I install anyway (y/n)? "; then
        exit 1;
    fi
fi

SELINUX_STATUS=$(getenforce 2>/dev/null)
HTTPD_T_STATUS=$(semanage permissive -l 2>/dev/null | grep httpd_t)
if [ -n "$SELINUX_STATUS" ]; then
    if [ "$SELINUX_STATUS" = "Permissive" ]; then
        logmsg "SELinux is enabled but in permissive mode."
    elif [ "$SELINUX_STATUS" = "Enforcing" ] && [ -z "$HTTPD_T_STATUS" ]; then
        printBanner "SELinux warning"
        logmsg "The installer has detected that SELinux is enabled on your system, and that it is set to enforce its policy and that there is no exception for httpd_t."
        logmsg "In this configuration it will prevent $APP_NAME from working. We recommend that you disable SELinux or at the very least, permit Apache in permissive mode."
        logmsg "See 'man 8 selinux' for details."

        if [ -n "$UNATTENDED" ] || input_yn "Should I set the Apache process in SELinux to permissive (y/n)? "; then
            execPrint "semanage permissive -a httpd_t 2>&1"
            HTTPD_T_STATUS=$(semanage permissive -l 2>/dev/null | grep httpd_t)
            if [ -z "$HTTPD_T_STATUS" ]; then
                logmsg "WARNING - Could not set HTTPD_T to permissive."
                logmsg "You as the system administrator will need to either disable SELinux or allow the HTTPD_T domain as permissive."
            fi
        fi

        if [ -z "$HTTPD_T_STATUS" ]; then
            input_text "Type CONTINUE to continue regardless of SELinux, or any other key to abort:"
            if [ "$RESPONSE" != "CONTINUE" ]; then
                logmsg "Aborting installation because of SELinux state.";
                exit 1;
            fi
        fi
    fi
fi

printBanner "Pre-requisites check and installation"

is_web_available=0
WEB_CHECK_URL="https://1.1.1.1"
logmsg "Checking if Web is accessible."

# curl is available even on minimal centos install
if [ "$SKIP_DEPENDENCIES" = "n" ]; then
    if type curl >/dev/null 2>&1 && execNoPrint "curl --insecure -Is -m 10 --retry 2 -o /dev/null $WEB_CHECK_URL 2>/dev/null"; then
            logmsg "Web access is OK."
            is_web_available=1
    fi
fi

if [ "$is_web_available" -eq 0 ] && [ "$SKIP_DEPENDENCIES" = "n" ]; then
    if type wget >/dev/null 2>&1 && execNoPrint "wget --no-check-certificate -q -T 10 --tries=3 -O /dev/null $WEB_CHECK_URL 2>/dev/null"; then
            logmsg "Web access is OK."
            is_web_available=1
    fi
fi

if [ "$is_web_available" -eq 0 ] && [ "$SKIP_DEPENDENCIES" = "n" ]; then
    logmsg "Your system cannot access the web, therefore $APP_NAME will not
    be able to download any missing software packages. If any
    such missing packages are detected and you don't have
    a local source of packages (e.g. an installation DVD) then $APP_NAME
    will not run successfully.

    Configure local package mirrors or contact $VENDOR_NAME: $VENDOR_URL"
fi

# Get any existing PHP versions
php_version=$(php --version 2>/dev/null | grep "^PHP " | cut -d" " -f2)
php_major_version=$(echo "$php_version" | cut -d. -f1)
php_minor_version=$(echo "$php_version" | cut -d. -f2)

# Centos 8
if [ "$SKIP_DEPENDENCIES" = "n" ] && [ "$is_web_available" -eq 1 ] && [ "$OS_MAJOR" -eq 8 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -eq 1 ]; then
    if [ -n "$UNATTENDED" ] || input_yn "Enable the repositories and install packages (y/n)? "; then
        logmsg "Enabling Centos/Rocky/Alma optional RPM repo (please wait)."
        logmsg "Running dnf update."
        execPrint "dnf -y upgrade 2>&1"
        execPrint "dnf -y install yum-utils 2>&1"
        logmsg "Enabling optional RPM repo (please wait)."
        execPrint "dnf -y config-manager --set-enabled powertools 2>&1"
        execPrint "dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_MAJOR.noarch.rpm 2>&1"
        execPrint "dnf -y install https://rpms.remirepo.net/enterprise/remi-release-$OS_MAJOR.rpm 2>&1"
        logmsg "Installing any missing packages."
        execPrint "dnf -y module reset php 2>&1"
        execPrint "dnf -y module install php:remi-8.2 2>&1"
        execPrint "dnf -y install mariadb-server httpd php php-cli php-gd php-intl php-mysqlnd php-ldap php-mbstring php-process php-snmp php-sodium php-xml php-zip nmap zip curl wget sshpass screen samba-client logrotate perl-Time-ParseDate ipmitool net-snmp net-snmp-utils perl-Crypt-CBC libnsl libsodium 2>&1"
        # Redhat does not enable these servers by default
        logmsg "Ensuring MySQL and Apache are enabled and running"
        for srv in php-fpm mariadb httpd; do
            if type systemctl >/dev/null 2>&1; then
                execPrint "systemctl enable $srv"
            else
                execPrint "chkconfig $srv"
            fi;
        done
        # Start / Restart the servers
        execPrint "systemctl restart php-fpm >/dev/null 2>&1"
        execPrint "systemctl restart httpd >/dev/null 2>&1"
        execPrint "systemctl restart mariadb >/dev/null 2>&1"

    else
        logmsg "You will need to ensure you have installed a PHP version of at least 8.2 and the sodium php extension."
        logmsg "The required packages are: mariadb-server httpd php php-cli php-gd php-intl php-mysqlnd php-ldap php-mbstring php-process php-snmp php-sodium php-xml php-zip nmap zip curl wget sshpass screen samba-client logrotate perl-Time-ParseDate ipmitool net-snmp net-snmp-utils perl-Crypt-CBC libnsl libsodium"
    fi
fi
if [ "$OS_MAJOR" -eq 8 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -eq 1 ]; then
    # SUID on the nmap binary
    logmsg "Setting SUID on Nmap binary"
    execPrint "chmod u+s /usr/bin/nmap"
fi


# Centos 9
if [ "$SKIP_DEPENDENCIES" = "n" ] && [ "$is_web_available" -eq 1 ] && [ "$OS_MAJOR" -eq 9 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -eq 1 ]; then
    if [ -n "$UNATTENDED" ] || input_yn "Enable the repositories and install packages (y/n)? "; then
        logmsg "Enabling Centos/Rocky/Alma optional RPM repo (please wait)."
        execPrint "dnf -y upgrade 2>&1"
        execPrint "dnf -y install yum-utils 2>&1"
        execPrint "dnf -y config-manager --set-enabled crb 2>&1"
        execPrint "dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_MAJOR.noarch.rpm 2>&1"
        execPrint "/usr/bin/crb enable 2>&1"
        execPrint "dnf -y install https://rpms.remirepo.net/enterprise/remi-release-$OS_MAJOR.rpm 2>&1"
        execPrint "dnf -y module reset php 2>&1"
        execPrint "dnf -y module install php:remi-8.2 2>&1"
        execPrint "dnf -y upgrade 2>&1"
        execPrint "dnf -y install mariadb-server httpd php php-cli php-gd php-intl php-mysqlnd php-ldap php-mbstring php-process php-snmp php-sodium php-xml php-zip nmap zip curl wget sshpass screen samba-client logrotate perl-Time-ParseDate ipmitool net-snmp net-snmp-utils perl-Crypt-CBC libnsl libsodium 2>&1"
        if grep -qF Alma /etc/redhat-release; then
            # Install this package for Alma
            execPrint "dnf -y install libxcrypt-compat 2>&1"
        fi
        # Redhat does not enable these servers by default
        logmsg "Ensuring MySQL and Apache are enabled and running"
        for srv in php-fpm mariadb httpd; do
            if type systemctl >/dev/null 2>&1; then
                execPrint "systemctl enable $srv"
            else
                execPrint "chkconfig $srv"
            fi;
        done
        # Start / Restart the servers
        execPrint "systemctl restart php-fpm >/dev/null 2>&1"
        execPrint "systemctl restart httpd >/dev/null 2>&1"
        execPrint "systemctl restart mariadb >/dev/null 2>&1"
    else
        logmsg "You will need to ensure you have installed a PHP version of at least 8.2 and the sodium php extension."
        logmsg "The required packages are: mariadb-server httpd php php-cli php-gd php-intl php-mysqlnd php-ldap php-mbstring php-process php-snmp php-sodium php-xml php-zip nmap zip curl wget sshpass screen samba-client logrotate perl-Time-ParseDate ipmitool net-snmp perl-Crypt-CBC libnsl libsodium"
    fi
fi
if [ "$OS_MAJOR" -eq 9 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -eq 1 ]; then
    # SUID on the nmap binary
    logmsg "Setting SUID on Nmap binary"
    execPrint "chmod u+s /usr/bin/nmap"
fi


# RedHat 8 and 9
if [ "$SKIP_DEPENDENCIES" = "n" ] && [ "$is_web_available" -eq 1 ] && [ "$OS_MAJOR" -ge 9 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -ne 1 ]; then
    if [ -n "$UNATTENDED" ] || input_yn "Install required packages (y/n)? "; then
        if [ -n "$(rpm -qa remi-release)" ]; then
            logmsg "Removing external Remi repo and associated PHP packages."
            execPrint "dnf -y remove remi-release 2>&1"
            execPrint "dnf -y module reset php 2>&1"
            execPrint "dnf -y update 2>&1"
            execPrint "subscription-manager refresh 2>&1"
            execPrint "dnf -y remove php php-cli php-gd php-intl php-mysqlnd php-ldap php-mbstring php-process php-snmp php-sodium php-xml libsodium 2>&1"
        fi

        execPrint "subscription-manager repos --enable codeready-builder-for-rhel-$OS_MAJOR-$(arch)-rpms 2>&1"
        execPrint "dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_MAJOR.noarch.rpm 2>&1"
        execPrint "/usr/bin/crb enable 2>&1"

        logmsg "Running dnf update."
        execPrint "dnf -y upgrade 2>&1"

        if [ "$OS_MAJOR" -eq 9 ]; then
            logmsg "Installing a suitable version of PHP (PHP 8.3)."
            execPrint "dnf -y module install php:8.3 --allowerasing"
        fi

        if [ "$OS_MAJOR" -eq 10 ]; then
            logmsg "Installing a suitable version of PHP (PHP 8.3)."
            execPrint "dnf -y module install php:8.3 --allowerasing"
        fi

        logmsg "Installing any missing packages."
        execPrint "dnf -y install --allowerasing curl httpd ipmitool libnsl libxcrypt-compat logrotate mariadb-server net-snmp net-snmp-utils nmap perl-Crypt-CBC perl-Time-ParseDate php-cli php-fpm php-gd php-intl php-ldap php-mysqlnd php-process php-snmp php-zip samba-client sshpass wget zip 2>&1"

        # Redhat does not enable these servers by default
        logmsg "Ensuring MySQL and Apache are enabled and running"
        for srv in php-fpm mariadb httpd; do
            if type systemctl >/dev/null 2>&1; then
                execPrint "systemctl enable $srv"
            else
                execPrint "chkconfig $srv"
            fi;
        done
        # Start / Restart the servers
        execPrint "systemctl restart php-fpm >/dev/null 2>&1"
        execPrint "systemctl restart httpd >/dev/null 2>&1"
        execPrint "systemctl restart mariadb >/dev/null 2>&1"
    fi
fi
if [ "$OS_MAJOR" -ge 8 ] && [ "$OSFLAVOUR" = "redhat" ] && [ "$OS_ISCENTOS" -ne 1 ]; then
    # SUID on the nmap binary
    logmsg "Setting SUID on Nmap binary"
    execPrint "chmod u+s /usr/bin/nmap"

    # Configure the firewall
    firewall_status=$(firewall-cmd --state 2>/dev/null)
    zone=$(firewall-cmd --get-default-zone 2>/dev/null)
    http_status="denied"
    if [ -n "$(firewall-cmd --list-all --zone=$zone 2>/dev/null | grep services: | grep http)" ]; then
        http_status="allowed"
    fi
    logmsg "INFO - Firewall status is $firewall_status. Firewall zone is: $zone. HTTP is $http_status."
    if [ "$firewall_status" = "running" ] && [ "$http_status" = "denied" ]; then
        if [ -n "$UNATTENDED" ] || input_yn "Should we allow port 80 through the firewall in the $zone zone (y/n)? "; then
            execPrint "firewall-cmd --zone=$zone --add-service=http --permanent"
            execPrint "firewall-cmd --reload"
        fi
    fi
fi


# Ubuntu 20, 22, 24
if [ "$SKIP_DEPENDENCIES" = "n" ] && [ "$is_web_available" -eq 1 ] && [ "$OS_MAJOR" -ge 22 ] && [ "$OSFLAVOUR" = "ubuntu" ]; then
    if [ -n "$UNATTENDED" ] || input_yn "Install packages (y/n)? "; then
        execPrint "apt-get update -qq 2>&1"
        execPrint "apt-get -yq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install cron mariadb-server apache2 apache2-utils libapache2-mod-php openssh-client php php-cli php-curl php-gd php-intl php-ldap php-mbstring php-mysql php-snmp php-xml php-zip nmap zip wget curl sshpass screen smbclient logrotate ipmitool snmp libcrypt-cbc-perl 2>&1"
        # Start / Restart the servers
        execPrint "systemctl restart apache2 >/dev/null 2>&1"
        execPrint "systemctl restart mysql >/dev/null 2>&1"
    else
        logmsg "You will need to ensure you have installed a PHP version of at least 7.4 and the sodium php extension."
        logmsg "The required packages are: cron mariadb-server apache2 apache2-utils libapache2-mod-php openssh-client php php-cli php-curl php-gd php-intl php-ldap php-mbstring php-mysql php-snmp php-xml php-zip nmap zip wget curl sshpass screen smbclient logrotate ipmitool snmp libcrypt-cbc-perl"
    fi
fi
if [ "$OS_MAJOR" -ge 20 ] && [ "$OSFLAVOUR" = "ubuntu" ]; then
    # SUID on the nmap binary
    execPrint "chmod u+s /usr/bin/nmap"
    execPrint "dpkg-statoverride --update --add root root 4755 /usr/bin/nmap"
fi


# Debian 11, 12
if [ "$SKIP_DEPENDENCIES" = "n" ] && [ "$is_web_available" -eq 1 ] && [ "$OS_MAJOR" -ge 12 ] && [ "$OSFLAVOUR" = "debian" ]; then
    if [ -n "$UNATTENDED" ] || input_yn "Install packages (y/n)? "; then
        execPrint "apt-get update -qq 2>&1"
        execPrint "apt-get -yq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold install cron mariadb-server apache2 apache2-utils libapache2-mod-php openssh-client php php-cli php-curl php-gd php-intl php-ldap php-mbstring php-mysql php-snmp php-xml php-zip nmap zip wget curl sshpass screen smbclient logrotate ipmitool snmp libcrypt-cbc-perl 2>&1"
        # Start / Restart the servers
        execPrint "systemctl restart apache2 >/dev/null 2>&1"
        execPrint "systemctl restart mysql >/dev/null 2>&1"
    else
        logmsg "You will need to ensure you have installed a PHP version of at least 7.4 and the sodium php extension."
        logmsg "The required packages are: cron mariadb-server apache2 apache2-utils libapache2-mod-php openssh-client php php-cli php-curl php-gd php-intl php-ldap php-mbstring php-mysql php-snmp php-xml php-zip nmap zip wget curl sshpass screen smbclient logrotate ipmitool snmp libcrypt-cbc-perl"
    fi
fi
if [ "$OS_MAJOR" -ge 11 ] && [ "$OSFLAVOUR" = "debian" ]; then
    # SUID on the nmap binary
    execPrint "chmod u+s /usr/bin/nmap"
    execPrint "dpkg-statoverride --update --add root root 4755 /usr/bin/nmap"
fi


php_version=$(php --version | grep "^PHP " | cut -d" " -f2)
php_major_version=$(echo "$php_version" | cut -d. -f1)
php_minor_version=$(echo "$php_version" | cut -d. -f2)
if [ "$php_major_version" -lt 8 ]; then
    logmsg "WARNING - Your PHP is version $php_version. $APP_NAME requires a minimum PHP of 8.2. Exiting."
    exit 1
fi
if [ "$php_major_version" -eq 8 ] && [ "$php_minor_version" -lt 2 ]; then
    logmsg "WARNING - Your PHP is version $php_version. $APP_NAME requires a minimum PHP of 8.2. Exiting."
    exit 1
fi
logmsg "INFO - Your PHP is version $php_version. $APP_NAME requires a minimum PHP of 8.2. You are good to go."

