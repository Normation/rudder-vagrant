#!/bin/sh

EXIT=0
for url in $(grep "^[[:space:]]*:url" Vagrantfile | perl -pe 's/.*"(.*)".*/$1/')
do
  code=$(curl -s -w "%{http_code}\n" -L -I ${url} | tail -n 1)
  if [ "${code}" != 200 ]
  then
    echo "Error, can't retreive $url"
    EXIT=1
  fi
done

exit ${EXIT}
