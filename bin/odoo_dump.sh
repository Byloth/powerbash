#!/usr/bin/env bash
#

set -e

source "$(dirname "${0}")/../lib/odoo.sh"

# Is Postgres client available on this local machine?
#
    readonly PG_DUMP="pg_dump"

# Is Postgres client available inside a Docker container?
#
    readonly POSTGRES="<postgres container>"
    readonly PG_DUMP="docker exec -i ${POSTGRES} pg_dump -U ${PGUSER}"

readonly BACKUP_DIR="./backups"
readonly TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"

read -p "Database name: " DATABASE

readonly FILEPATH="${BACKUP_DIR}/${DATABASE}"
readonly FILENAME="${NAME}_${TIMESTAMP}.tar.gz"

mkdir -p "${FILEPATH}"
cd "${FILEPATH}"

echo -e "Dumping database... \c"
${PG_DUMP} -b -Fc -d "${DATABASE}" -O > "${DATABASE}.dump"
echo -e "\e[32mOK!\e[0m"

echo -e "Copying filestore... \c"
docker cp "${NAME}:/var/lib/odoo/filestore/${DATABASE}" . &> /dev/null
echo -e "\e[32mOK!\e[0m"

cd ..

echo -e "Compressing backup... \c"
tar -czvf "${FILENAME}" "${DATABASE}" &> /dev/null
echo -e "\e[32mOK!\e[0m"

echo -e "Removing temporary directories... \c"
rm -rf "${DATABASE}" &> /dev/null
echo -e "\e[32mOK!\e[0m"

echo -e "\nDone!"
echo -e " └ $ $(dirname "${0}")/odoo_restore.sh \"${BACKUP_DIR}/${FILENAME}\"\n"
