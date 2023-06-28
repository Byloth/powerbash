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
    echo -e "\e[33;4m${1}\e[0m"
}
function error()
{
    echo -e "\e[31;4m${1}\e[0m"
}
