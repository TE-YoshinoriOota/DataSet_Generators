#!/bin/bash
if [ $# -ne 5 ]; then
  echo "-a -b xxx -c ddd"
  exit 0
fi
while getopts ab:c: OPT
do
  case $OPT in
    "a" ) FLG_A="TRUE" ;;
    "b" ) FLG_B="TRUE" ; VALUE_B="$OPTARG" ;;
    "c" ) FLG_C="TRUE" ; VALUE_C="$OPTARG" ;;
  esac
done
echo "$VALUE_B"
echo "$VALUE_C"
