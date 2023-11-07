#!/bin/bash


for app in $(kubectl get app -n tap-install  | grep -v "NAME" | awk '{print $1}'); do
 echo $app
 kubectl patch app/$app -n tap-install -p '[{"path":"/metadata/finalizers","op": "remove"}]'  --type=json
done
