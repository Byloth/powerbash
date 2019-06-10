#!/usr/bin/env bash
#

function success()
{
    echo -e "\e[32m${1}\e[0m"
}
function info()
{
    echo -e "\e[36m${1}\e[0m"
}
function warning()
{
    echo -e "\e[4;33m${1}\e[0m"
}
function error()
{
    echo -e "\e[4;31m${1}\e[0m"
}
