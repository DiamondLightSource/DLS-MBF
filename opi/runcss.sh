#!/bin/bash

set -x

CSS_RUN_SCRIPT="$(configure-ioc s -p CSS-gui)"
SCRIPT_DIR="$(cd "$(dirname "$0")"  &&  pwd)"

LINKS="$SCRIPT_DIR=/MBF/opi"

MACROS='device=TS-DI-TMBF-02,axis0=X,axis1=Y,mode=TMBF'

exec "$CSS_RUN_SCRIPT" -s -l "$LINKS" -m "$MACROS" -o /MBF/opi/css/TMBF.opi
