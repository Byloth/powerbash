#!/usr/bin/env bash
#

source "$(dirname "${0}")/../lib/odoo.sh"

clear

echo -e "\n  I'm going to start a new Odoo instance..."
echo -e "   ├ Container name: $(info "${NAME}")"

if [ "${VERSION}" != "${LAST_VERSION}" ]
then
    echo -e "   ├ Image tag: $(info "${IMAGE}"):$(warning "${VERSION}")"
else
    echo -e "   ├ Image tag: $(info "${IMAGE}"):$(info "${VERSION}")"
fi

echo -e "   │"

if [ "${PORT}" != "80" ]
then
    echo -e "   └ URL: $(info "http://localhost:${PORT}/web?debug")"
else
    echo -e "   └ URL: $(info "http://localhost/web?debug")"
fi

if [ -n "$(dockerFind "${NAME}")" ]
then
    echo -e "\n   ------------------------------"
    echo -e "\n  $(warning "WARNING"): There is already another Docker"
    echo -e "   container running with the same name...\n"
    read -p "  Do you wish to stop it? [Y]: " ANSWER

    if [ -z "${ANSWER}" ] || [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]
    then
        echo -e "   └ I'm stopping it... \c"

        dockerStop "${NAME}"
    else
        echo -e "   └ Ok... No problem!"

        exit 0
    fi
fi

if [ "${HAVE_TO_PULL}" == "true" ]
then
    echo -e "\n  Pulling fresh image..."
    echo -e " ------------------------------\n"

    odooPull
fi

echo -e "\n  Start logging..."
echo -e " ------------------------------\n"

odooRun ${@}
