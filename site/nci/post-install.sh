#!/bin/bash

# Post-install tasks

set -eu
set -o pipefail

mkdir -p "$(dirname "$NGMOENVS_MODULE")"
cat > "$NGMOENVS_MODULE" << EOF
#%Module1.0

set name         "$ENVIRONMENT"
set version      "$VERSION"
set origin       "$(git remote get-url origin) $(git rev-parse HEAD)"
set install_date "$(date --iso=minute)"
set installed_by "$USER - $(getent passwd "$USER" | cut -d ':' -f 5)"
set prefix       "$INSTALL_ENVDIR"

proc ModulesHelp {} {
    global name version origin install_date installed_by

    puts stderr "NGMO Environment \$name/\$version"
    puts stderr "  Install info:"
    puts stderr "    repo: \$origin"
    puts stderr "    ver:  \$version"
    puts stderr "    date: \$install_date"
    puts stderr "    by:   \$installed_by"
}

set name_upcase [string toupper [string map {- _} \$name]]

setenv \${name_upcase}_NGMOENV_ROOT "\$prefix"
setenv \${name_upcase}_NGMOENV_VERSION "\$version"

prepend-path PATH "\$prefix/bin"
EOF

mkdir -p "$INSTALL_ENVDIR/bin"

# If installing through a container use the site-specific 'envrun',
# if not then the default will get installed
for script in "$SITE_DIR/bin"/*; do
    cp "$script" "$INSTALL_ENVDIR/bin"
done

# Old launcher name
ln -sf "envrun" "$INSTALL_ENVDIR/bin/imagerun"

# Make rose commands run inside the container
ln -sf "envrun-external" "$INSTALL_ENVDIR/bin/rose"

# Environment specific commands
# commands.sh defines array ENV_COMMANDS with names to link
COMMANDFILE="$NGMOENVS_DEFS/environments/$ENVIRONMENT/commands.sh"
if [[ -f "$COMMANDFILE" ]]; then
    source "$COMMANDFILE"

    for cmd in "${ENV_COMMANDS[@]}"; do
        ln -sf "envrun-wrapped" "$INSTALL_ENVDIR/bin/$cmd"
    done
fi

cat <<EOF

Environment build complete

Load the environment with

    module load "$NGMOENVS_MODULE"

Prepend commands with 'envrun' to run them in the container
EOF
