#!/bin/sh
set -e

export PORT=${PORT:-8000}
export REPO_URL=${REPO_URL:-http://autolandhg:8000/}
export REPO_NAME=${REPO_NAME:-test-repo}

/create-config.py $AUTOLAND_HOME/autoland/config.json
envsubst < /httpd.conf.template > /etc/apache2/httpd.conf

case "${1:-api}" in
    "init")
        echo Initialising Database
        $AUTOLAND_HOME/venv/bin/python /create-schema.py $AUTOLAND_HOME
        ;;
    "api")
        echo Starting autoland HTTPD on port $PORT
        exec httpd -DFOREGROUND
        ;;
    "daemon")
        if [[ ! -d /repos/$REPO_NAME ]]; then
            echo Cloning $REPO_NAME from $REPO_URL
            hg clone $REPO_URL /repos/$REPO_NAME
            envsubst < /hgrc.template > /repos/$REPO_NAME/.hg/hgrc
        fi
        cd $AUTOLAND_HOME
        . venv/bin/activate
        cd autoland
        exec python autoland.py
        ;;
    *)
        exec $*
        ;;
esac

