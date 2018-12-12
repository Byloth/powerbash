#!/usr/bin/env bash
#

readonly FILESTORE="/var/lib/odoo/filestore"

readonly CONTAINER="<container>"

export PGHOST="<pghost>"
export PGPORT="<pgport>"
export PGUSER="<pguser>"
export PGPASSWORD="<pgpassword>"

readonly ARCHIVE="${1}"

if [ -z "${ARCHIVE}" ]
then
    echo "Usage: $(basename "${0}") <path/to/dump/file.tar.gz>"

    exit -1
fi

read -p "New database name: " DATABASE

readonly EXTRACT_DIR="${ARCHIVE%".tar.gz"}"

mkdir -p "${EXTRACT_DIR}"

echo -e "Extracting backup... \c"
tar -xzvf "${ARCHIVE}" -C "${EXTRACT_DIR}" &> /dev/null
echo -e "\033[0;32mOK!\033[0m"

readonly OLD_DATABASE=$(ls "${EXTRACT_DIR}")

cd "${EXTRACT_DIR}/${OLD_DATABASE}"

echo -e "Creating new database... \c"
createdb "${DATABASE}"
echo -e "\033[0;32mOK!\033[0m"

echo -e "Restoring database... \c"
pg_restore -Fc -d "${DATABASE}" -O "${OLD_DATABASE}.dump"
echo -e "\033[0;32mOK!\033[0m"

echo -e "Copying filestore... \c"
docker cp "${OLD_DATABASE}" "${CONTAINER}:${FILESTORE}/"
echo -e "\033[0;32mOK!\033[0m"

echo -e "Renaming filestore... \c"
docker exec ${CONTAINER} if [ -d "${FILESTORE}/${DATABASE}" ]; then rm -rf "${FILESTORE}/${DATABASE}"; fi
docker exec ${CONTAINER} mv "${FILESTORE}/${OLD_DATABASE}" "${FILESTORE}/${DATABASE}"
echo -e "\033[0;32mOK!\033[0m"

echo -e "Changing permissions on filestore... \c"
docker exec ${CONTAINER} chown -R odoo:odoo "${FILESTORE}/${DATABASE}"
echo -e "\033[0;32mOK!\033[0m"

cd ../..

echo -e "Removing temporary directories... \c"
rm -rf "${EXTRACT_DIR}" &> /dev/null
echo -e "\033[0;32mOK!\033[0m"

echo -e "\nDone!\n"
