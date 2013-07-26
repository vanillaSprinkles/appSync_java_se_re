#!/bin/bash

DLTF=/tmp/tmpdlfile.dl

wget --quiet -q http://www.oracle.com/technetwork/java/javase/downloads/java-se-binaries-checksum-1956892.html -O "${DLTF}"

APPnMD5=("$(grep -s -E -A1 ">jre-[0-9]*u[0-9]*-.*\.[0-9a-z]*[0-9.a-z]*<" "${DLTF}" | grep -v "\-\-" | sed 's/<[/]*td>//g')")
#.*>[0-9a-zA-Z]{32}<" "${DLTF}"
APPnMD5_sz=${#APPnMD5[@]}

for (( i=0; i<APPnMD5_sz; i++ )); do
  if (( i%2 == 0 )); then
      echo "${APPnMD5[$i]}"
  else
      echo "${APPnMD5[$i]}"
  fi
done

