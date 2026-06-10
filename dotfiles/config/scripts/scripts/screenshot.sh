#!/usr/bin/env bash
grim -g "$(slurp)" - | swappy -f - -o - > ~/Documents/Screenshots/$(date +'%Y-%m-%d-%H:%M:%S.png')
