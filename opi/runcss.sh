#!/bin/bash

HERE="$(cd "$(dirname "$0")"  &&  pwd)"

CSS_RUN_SCRIPT="$(configure-ioc s -p CSS-gui)"

LINKS="$HERE=/MBF/opi"

exec "$CSS_RUN_SCRIPT" -s -l "$LINKS" -o /MBF/opi/css/mbf_launcher.opi
