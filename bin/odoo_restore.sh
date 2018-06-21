#!/usr/bin/env bash
#

readonly CONTAINER="<container>"

export PGHOST="127.0.0.1"
export PGUSER="<pguser>"
export PGPASSWORD="<pgpassword>"

readonly DUMP="${1}"
readonly OLD_DATABASE=$(basename "${DUMP}")

if [ -z "${DUMP}" ]
then
    echo "Missing 1st parameter. Stopping..."
else
    read -p "Database name: " DATABASE

    echo "Restoring database..."
    createdb "${DATABASE}"
    pg_restore -Fc -d "${DATABASE}" -O "${DUMP}.dump"

    echo "Copying filestore..."
    docker cp "${DUMP}" "${CONTAINER}:/var/lib/odoo/filestore/"
    docker exec ${CONTAINER} mv "/var/lib/odoo/filestore/${OLD_DATABASE}" "/var/lib/odoo/filestore/${DATABASE}"
fi
