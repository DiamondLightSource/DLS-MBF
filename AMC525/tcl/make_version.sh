#!/bin/bash

# Shell script for creating VHDL version file

set -e

# First argument specifies where to place the file we're going to build
TARGET_FILE="${1?:Must specify target file}"

TOP="$(dirname "$0")"/../..

set -o pipefail

# First pick up the git information
if GIT_SHA=$(cd "$TOP"; git rev-parse HEAD | cut -b -7); then
    # Ok, we have a valid git repository
    GIT_DIRTY=$(cd "$TOP"; git diff-index --quiet HEAD; echo $?)
else
    # No git repository, create default values instead
    GIT_SHA=0000000
    GIT_DIRTY=1
fi

# Now pick up the version file.  This is in makefile format, so we get make to
# convert it for us
eval "$(make -C "$TOP" print_version --no-print-directory)"

cat <<EOF >"$TARGET_FILE"
package version is
    constant GIT_VERSION : natural := 16#$GIT_SHA#;
    constant GIT_DIRTY : natural := $GIT_DIRTY;
    constant VERSION_MAJOR : natural := $VERSION_MAJOR;
    constant VERSION_MINOR : natural := $VERSION_MINOR;
    constant VERSION_PATCH : natural := $VERSION_PATCH;
end;
EOF
