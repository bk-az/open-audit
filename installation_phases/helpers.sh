logmsg() {
    if [ ! -f "$LOGFILE" ]; then
        touch "$LOGFILE"
    fi
    if [ -f "$LOGFILE" ]; then
            echo "$@" >> $LOGFILE
    fi
    echo "$@"
    return 0;
}

logmsgNoPrint() {
    if [ ! -f "$LOGFILE" ]; then
        touch "$LOGFILE"
    fi
    if [ -f "$LOGFILE" ]; then
            echo "$@" >> $LOGFILE
    fi
    return 0;
}

input_yn() {
    MSG="$1"
    while true; do
        read -p "$MSG" yn
        case $yn in
            [Yy]* ) logmsg "$MSG y"; return 0; break;;
            [Nn]* ) logmsg "$MSG n"; return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}


# print prompt, print static blurb, read response string and
# export it as RESPONSE
# in unattended mode the response is ''
input_text() {
    local MSG TAG
    MSG="$1"
    TAG="${2:-}"

    if [ -z "${TAG}" ]; then
        logmsg "input_text: MSG=${MSG}: TAG='': No preseed question. Continuing..." 1;
    fi;

    RESPONSE=''
    echo -n "$MSG"
    if [ -n "$UNATTENDED" ]; then
        logmsg "Automatic blank input for '$MSG' in unattended mode"
        echo "(auto-default empty response)"
    else
        read RESPONSE
        logmsg "User input for '$MSG': '$RESPONSE'"
    fi
    export RESPONSE
}

printBanner() {
    echo
    echo
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "$@"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo

    if [ -f "$LOGFILE" ]; then
            echo '###+++' >> $LOGFILE
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $LOGFILE
            echo "$@" >> $LOGFILE
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $LOGFILE
            echo '###+++' >> $LOGFILE
    fi
    return 0;
}

# run cmd, capture output and stderr and append to logfile
execPrint()
{
    logmsg ""
    logmsg "###+++"
    RES=0
    OUTPUT=$(eval "$@" 2>&1)||RES=$?
    # pre-initialised RES=0 before loop so we don't need a default value here
    if [ "${RES}" = 0 ]; then
        logmsg "EXEC: $*" "${RES}" "${OUTPUT}";
        break
    else
        logmsg "EXEC: $*" "${RES}" "${OUTPUT}";
        logmsg "execPrint '$*' failed."
    fi
    logmsg ""
    return $RES
}

# run cmd, capture output and stderr and append to logfile
execNoPrint()
{
    logmsgNoPrint ""
    RES=0
    OUTPUT=$(eval "$@" 2>&1)||RES=$?
    # pre-initialised RES=0 before loop so we don't need a default value here
    if [ "${RES}" = 0 ]; then
        logmsgNoPrint "EXEC: $*" "${RES}" "${OUTPUT}";
        break
    else
        logmsgNoPrint "EXEC: $*" "${RES}" "${OUTPUT}";
        logmsg "execNoPrint '$*' failed."
    fi
    logmsgNoPrint ""
    return $RES
}

check_missing_packages() {
    local PKG
    MISSING=''
    for PKG in "$@"; do
        if [ "$OSFLAVOUR" = "redhat" ]; then
            if [ -z $(rpm -qa "$PKG") ]; then
                MISSING="$MISSING $PKG";
                logmsg "Package $PKG is NOT installed."
            else
                logmsg "Package $PKG is installed.";
            fi
        elif [ "$OSFLAVOUR" = "debian" ] || [ "$OSFLAVOUR" = "ubuntu" ]; then
            if ! $(dpkg -l "$PKG" 2>/dev/null | grep -qE "^[hi]i"); then
                MISSING="$MISSING $PKG"
                logmsg "Package $PKG is NOT installed."
            else
                logmsg "Package $PKG is installed."
            fi
        fi
    done
    [ -z "$MISSING" ] && return 0
    return 1
}

detect_running_release() {
    RUNNING_RELEASE_DIR=""
    if [ -L "$INSTALL_DIR/current" ]; then
        RUNNING_RELEASE_DIR=$(readlink -f "$INSTALL_DIR/current")
        return 0
    fi
    if [ -d "$INSTALL_DIR/app" ]; then
        RUNNING_RELEASE_DIR="$INSTALL_DIR"
        return 0
    fi
    if [ -d "$FALLBACK_INSTALL_DIR" ] && [ ! -L "$FALLBACK_INSTALL_DIR" ]; then
        RUNNING_RELEASE_DIR="$FALLBACK_INSTALL_DIR"
        return 0
    fi
}

# guesses os and sets $OSFLAVOUR to debian, ubuntu, redhat or '',
# also sets OS_VERSION, OS_MAJOR, OS_MINOR (and OS_PATCH if it exists),
# plus OS_ISCENTOS if flavour is redhat.
detect_os() {
    printBanner "OS Detection"
    if [ -f "/etc/redhat-release" ]; then
            OSFLAVOUR=redhat
            logmsg "Detected OS flavour RedHat/CentOS/Rocky/Alma"
            # centos7: ugly triplet and gunk, eg. "CentOS Linux release 7.2.1511 (Core)"
            OS_VERSION=$(sed -re 's/(^|.* )([0-9]+\.[0-9]+(\.[0-9]+)?).*$/\2/' < /etc/redhat-release)
            OS_ISCENTOS=0;
            if grep -qF CentOS /etc/redhat-release; then
                logmsg "detected CentOS derivative of RHEL: OS_VERSION='${OS_VERSION}'"
                OS_ISCENTOS=1;
            elif grep -qF Rocky /etc/redhat-release; then
                logmsg "detected Rocky OS derivative of RHEL: OS_VERSION='${OS_VERSION}'"
                OS_ISCENTOS=1;
            elif grep -qF Alma /etc/redhat-release; then
                logmsg "detected Alma OS derivative of RHEL: OS_VERSION='${OS_VERSION}'"
                OS_ISCENTOS=1;
            elif grep -qF Fedora /etc/redhat-release; then
                OS_ISCENTOS=1;
                OS_VERSION=`sed -re 's/(^|.* )([0-9]+).*$/\2/' < /etc/redhat-release`;
                if [ "${OS_VERSION}" -ge 28 ]; then
                    OS_VERSION='8.0.0';
                elif [ "${OS_VERSION}" -ge 19 ]; then
                    OS_VERSION='7.0.0';
                elif [ "${OS_VERSION}" -ge 12 ]; then
                    OS_VERSION='6.0.0';
                fi;
                logmsg "Detected derivative of RHEL: OS_VERSION='${OS_VERSION}'"
            fi;

            # ensure OS_ISCENTOS is defined:
            OS_ISCENTOS="${OS_ISCENTOS:-0}";

    elif grep -q ID=debian /etc/os-release ; then
        OSFLAVOUR=debian
        logmsg "detected OS flavour Debian"
        OS_VERSION=$(cat /etc/debian_version)
    elif grep -q ID=ubuntu /etc/os-release ; then
        OSFLAVOUR=ubuntu
        logmsg "Detected OS flavour Ubuntu"
        OS_VERSION=$(grep VERSION_ID /etc/os-release | sed -re 's/^VERSION_ID="([0-9]+\.[0-9]+(\.[0-9]+)?)"$/\1/')
    fi

    OS_VERSION="${OS_VERSION:-}";
    OS_MAJOR=$(echo "$OS_VERSION" | cut -s -f 1 -d .)
    OS_MAJOR="${OS_MAJOR:-0}";
    OS_MINOR=$(echo "$OS_VERSION" | cut -s -f 2 -d .)
    OS_MINOR="${OS_MINOR:-0}";
    OS_PATCH=$(echo "$OS_VERSION" | cut -s -f 3 -d .)
    OS_PATCH="${OS_PATCH:-0}";

    logmsg "OSFLAVOUR=${OSFLAVOUR}"
    logmsg "OS_VERSION=${OS_VERSION}"
    logmsg "OS_MAJOR=${OS_MAJOR}"
    logmsg "OS_MINOR=${OS_MINOR}"
    logmsg "OS_PATCH=${OS_PATCH}"
}
