#!/usr/bin/env bash
pv ./secrets/sd-card.img | sudo dd oflag=direct bs=32M of=$1 && sync
