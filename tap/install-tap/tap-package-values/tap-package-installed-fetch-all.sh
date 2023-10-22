#!/bin/bash

for app in $(kubectl get app -n tap-install | awk '{print $1}' | grep -v "NAME" | sort ); do
  ./tap-package-installed-fetch-metadata.sh $app
done