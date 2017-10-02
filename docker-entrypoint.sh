#!/bin/bash

sed -i -e "s~elHost~$ELASTICSEARCH_HOST~g" /curator/curator.yml
sed -i -e "s~olderthan~$OLDER_THAN_IN_DAYS~g" /curator/delete_indice.yml

set -ex

# Add curator as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- curator "$@"
fi

# Step down via gosu
if [ "$1" = 'curator' ]; then
	exec gosu curator bash -c "while true; do curator /curator/delete_indice.yml --config /curator/curator.yml; set -e; sleep $(( 60*60*INTERVAL_IN_HOURS )); set +e; done"
fi

# As argument is not related to curator,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
