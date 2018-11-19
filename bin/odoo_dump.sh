#!/usr/bin/env bash
#

readonly CONTAINER="<container>"

readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly FILENAME="${CONTAINER}_${TIMESTAMP}"

readonly BACKUP_DIR="./backups/"

export PGHOST="127.0.0.1"
export PGUSER="<pguser>"
export PGPASSWORD="<pgpassword>"

read -p "Database name: " DATABASE

mkdir -p "${BACKUP_DIR}${FILENAME}"
cd "${BACKUP_DIR}${FILENAME}"

echo "Dumping database..."
pg_dump -b -Fc -d "${DATABASE}" -O > "${DATABASE}.dump"

echo "Copying filestore..."
docker cp "${CONTAINER}:/var/lib/odoo/filestore/${DATABASE}" .

echo "Done! -> $ ./<instance-name>_restore.sh \"${BACKUP_DIR}${FILENAME}\""
