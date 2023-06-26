#!/bin/sh
set -e

# if there is no nsd.conf, turn the sample into a real config
if [ ! -f ${NSD_HOME_DIR}/nsd.conf ]; then
	mv ${NSD_HOME_DIR}/nsd.conf.sample ${NSD_HOME_DIR}/nsd.conf
# else delete sample if it exists
elif [ -f ${NSD_HOME_DIR}/nsd.conf.sample ]; then
	rm ${NSD_HOME_DIR}/nsd.conf.sample
fi

# pass control to the command provided
exec "$@"
