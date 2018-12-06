#!/usr/bin/env bash
#

readonly BACKUP_DIR="./backups"
readonly TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

readonly CONTAINER="<container>"

export PGHOST="<pghost>"
export PGUSER="<pguser>"
export PGPASSWORD="<pgpassword>"

read -p "Database name: " DATABASE

readonly FILEPATH="${BACKUP_DIR}/${DATABASE}"
readonly FILENAME="${CONTAINER}_${TIMESTAMP}.tar.gz"

mkdir -p "${FILEPATH}"
cd "${FILEPATH}"

echo -e "Dumping database... \c"
pg_dump -b -Fc -d "${DATABASE}" -O > "${DATABASE}.dump"
echo -e "\033[0;32mOK!\033[0m"

echo -e "Copying filestore... \c"
docker cp "${CONTAINER}:/var/lib/odoo/filestore/${DATABASE}" . &> /dev/null
echo -e "\033[0;32mOK!\033[0m"

cd ..

echo -e "Compressing backup... \c"
tar -czvf "${FILENAME}" "${DATABASE}" &> /dev/null
echo -e "\033[0;32mOK!\033[0m"

echo -e "Removing temporary directories... \c"
rm -rf "${DATABASE}" &> /dev/null
echo -e "\033[0;32mOK!\033[0m"

echo -e "\nDone!"
echo -e " └ $ $(dirname "${0}")/odoo_restore.sh \"${BACKUP_DIR}/${FILENAME}\"\n"
