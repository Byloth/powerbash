#!/usr/bin/env bash
#

function _crypt-password()
{
    local PYTHON_SCRIPT="
from passlib.context import CryptContext
passwd = CryptContext(schemes=['pbkdf2_sha512'])
print(passwd.hash('${1}'))
"
    echo "$(python -c "${PYTHON_SCRIPT}")"
}

function _odoo-reset()
{
    local PYTHON_SCRIPT="
import uuid
print(uuid.uuid4())
"
    local DATABASE_UUID="$(python -c "${PYTHON_SCRIPT}")"
    _psql-query "UPDATE ir_config_parameter SET value = '${DATABASE_UUID}' WHERE key = 'database.uuid';" "${@}"

    local DATABASE_SECRET="$(python -c "${PYTHON_SCRIPT}")"
    _psql-query "UPDATE ir_config_parameter SET value = '${DATABASE_SECRET}' WHERE key = 'database.secret';" "${@}"

    local MOBILE_UUID="$(python -c "${PYTHON_SCRIPT}")"
    _psql-query "UPDATE ir_config_parameter SET value = '${MOBILE_UUID}' WHERE key = 'mobile.uuid';" "${@}"

    _psql-query "UPDATE ir_config_parameter SET value = '2021-12-31 23:59:59' WHERE key = 'database.expiration_date';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = 'renewal' WHERE key = 'database.expiration_reason';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'database.enterprise_code';" "${@}"

    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'website_slides.google_app_key';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'google_calendar_client_id';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'google_calendar_client_secret';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'google_drive_client_id';" "${@}"
    _psql-query "UPDATE ir_config_parameter SET value = '' WHERE key = 'google_drive_client_secret';" "${@}"

    _psql-query "DELETE FROM fetchmail_server;" "${@}"
    _psql-query "DELETE FROM ir_cron;" "${@}"
    _psql-query "DELETE FROM ir_mail_server;" "${@}"
}

function odoo-change-password-legacy()
{
    echo ""
    read -s -p "New Odoo password for user \"admin\": " NEW_PASSWD
    echo ""

    _psql-query "UPDATE res_users SET password_crypt = '$(_crypt-password "${NEW_PASSWD}")' WHERE login = 'admin';" "${@}"
}
function odoo-change-password()
{
    echo ""
    read -s -p "New Odoo password for user \"admin\": " NEW_PASSWD
    echo ""

    _psql-query "UPDATE res_users SET password = '$(_crypt-password "${NEW_PASSWD}")' WHERE login = 'admin';" "${@}"
}
function odoo-make-dev-legacy()
{
    _odoo-reset "${@}"

    odoo-change-password-legacy "${@}"
}
function odoo-make-dev()
{
    _odoo-reset "${@}"

    odoo-change-password "${@}"
}
function odoo-remove-assets()
{
    _psql-query "DELETE FROM ir_attachment WHERE datas_fname SIMILAR TO '%.(css|js|less)';" "${@}"
}
