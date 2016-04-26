#!/bin/bash
set -e

if ! type -- "$1" &>/dev/null; then
    set -- java -jar "-Djava.io.tmpdir=$TMPDIR" "$JETTY_HOME/start.jar" "$@"
fi

echo "$JAAS_APPNAME"

if [ "$JAAS_APPNAME" ]; then
    /bin/echo "$JAAS_APPNAME" {  > "$JETTY_BASE/etc/login.conf"
    /bin/echo org.efaps.jaas.efaps.UserLoginModule >> "$JETTY_BASE/etc/login.conf"
    /bin/echo SUFFICIENT >> "$JETTY_BASE/etc/login.conf"
    /bin/echo debug=true >> "$JETTY_BASE/etc/login.conf"
    /bin/echo jaasSystem="\""eFaps"\";" >> "$JETTY_BASE/etc/login.conf"
    /bin/echo "};" >> "$JETTY_BASE/etc/login.conf"
fi

exec "$@"
