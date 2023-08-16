#!/bin/bash

APP=$1
kubectl patch packageinstall/$APP -n tap-install -p '{"spec":{"paused":true}}' --type=merge
