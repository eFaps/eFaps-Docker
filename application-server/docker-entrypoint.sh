#!/bin/bash

set -e

if ! type -- "$1" &>/dev/null; then
    set -- java -jar "-Djava.io.tmpdir=$TMPDIR" "$JETTY_HOME/start.jar" "$@"
fi

exec "$@"
