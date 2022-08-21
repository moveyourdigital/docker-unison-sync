#!/usr/bin/env bash
set -e

if [ "$1" == '/start.sh' ]; then
  export SOURCE=${ORIGIN:-/data}
  export INTERVAL=${INTERVAL:-60}
  export PORT=${PORT:-5001}

  # if source does not exist
  [ ! -d ${SOURCE} ] && mkdir -p ${SOURCE}

  # see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
	if [ -n ${TZ} ] && [ -f /usr/share/zoneinfo/${TZ} ]; then
		ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
		echo ${TZ} > /etc/timezone
	fi

  # if source default.prf does not exist
  if [ ! -f $UNISON/default.prf ]; then
    echo "Copying default.prf from source..."
    cp $UNISON_ETC/default.prf $UNISON/default.prf
  fi

  # if source default.prf has changed, copy to working directory
  if [ ! cmp $UNISON_ETC/default.prf $UNISON/default.prf > /dev/null 2>&1 ]; then
    echo "Warning: default.prf are not identical. Copying from source..."
    cp $UNISON_ETC/default.prf $UNISON/default.prf
  fi

  # Check if a script is available in /docker-entrypoint.d and source it
	for f in /docker-entrypoint.d/*; do
		case "$f" in
			*.sh) echo "$0: running $f"; . "$f" ;;
		esac
	done
fi

exec "$@"
