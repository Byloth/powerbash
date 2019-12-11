#!/usr/bin/env bash
#

set -e

readonly BACKUP_DIR="./backups"
readonly TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"

readonly CONTAINER="<container>"

export PGHOST="<pghost>"
export PGPORT="<pgport>"
export PGUSER="<pguser>"
export PGPASSWORD="<pgpassword>"

# Is Postgres client available on this local machine?
#
    readonly PG_DUMP="pg_dump"

# Is Postgres client available inside a Docker container?
#
    readonly POSTGRES="<postgres container>"
    readonly PG_DUMP="docker exec -i ${POSTGRES} pg_dump -U ${PGUSER}"

read -p "Database name: " DATABASE

readonly FILEPATH="${BACKUP_DIR}/${DATABASE}"
readonly FILENAME="${CONTAINER}_${TIMESTAMP}.tar.gz"

mkdir -p "${FILEPATH}"
cd "${FILEPATH}"

echo -e "Dumping database... \c"
${PG_DUMP} -b -Fc -d "${DATABASE}" -O > "${DATABASE}.dump"
echo -e "\e[32mOK!\e[0m"

echo -e "Copying filestore... \c"
docker cp "${CONTAINER}:/var/lib/odoo/filestore/${DATABASE}" . &> /dev/null
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
