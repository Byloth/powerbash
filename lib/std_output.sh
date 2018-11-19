#!/usr/bin/env bash
#

function success()
{
    echo -e "\033[0;32m${1}\033[0m"
}
function info()
{
    echo -e "\033[0;36m${1}\033[0m"
}
function warning()
{
    echo -e "\033[4;33m${1}\033[0m"
}
function error()
{
    echo -e "\033[4;31m${1}\033[0m"
}
