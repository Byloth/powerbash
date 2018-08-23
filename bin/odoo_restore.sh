#!/usr/bin/env bash
#

source "$(dirname ${0})/../lib/odoo.sh"

readonly DUMP="${1}"
readonly OLD_DATABASE=$(basename "${DUMP}")

if [ -z "${DUMP}" ]
then
    echo "Usage: $(basename "${0}") <path/to/dump/directory>"

    exit -1
fi

if [ -z "$(dockerFind "${NAME}")" ]
then
    echo -e "\n  $(warning "WARNING"): Docker container with name $(info "${NAME}")"
    echo -e "   seems not to be running...\n"
    echo -e "  Is the Docker container's name correct?"

    exit 1
fi

read -p "New database name: " DATABASE

echo "Restoring database..."
createdb "${DATABASE}"
pg_restore -Fc -d "${DATABASE}" -O "${DUMP}.dump"

echo "Copying filestore..."
docker cp "${DUMP}" "${NAME}:/var/lib/odoo/filestore/"
docker exec ${NAME} mv "/var/lib/odoo/filestore/${OLD_DATABASE}" "/var/lib/odoo/filestore/${DATABASE}"
docker exec ${NAME} chown -R odoo:odoo "/var/lib/odoo/filestore/${DATABASE}"
