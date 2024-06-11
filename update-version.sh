#!/bin/sh

version="$1"

[ -z "${version}" ] && echo "You need to specify a version" && exit 1
echo "${version}" | grep -q "^v" && echo "Do not use 'v' at the beginning of version" && exit 1

sed -i "s|DEVPOD_VERSION: .*|DEVPOD_VERSION: ${version}|g" ./sh.loft.devpod.yml
