#!/bin/bash

# apt update
# apt install -y pkg-config udev libudev-dev usbutils

# rustup component add llvm-tools-preview

# cargo install cargo-binutils
# cargo install cargo-embed

# apt install -y gdb-multiarch minicom

# ----------------------------------------

# Create the PROJECT_NAME from the device specific folder we are
# running in - note that this uses bash variable manipulation and
# assumes the path is coming from Windows and looks like:
#
# c:\foo\bar\baz\project-folder
#
# It MIGHT also work coming from Linux but I'm not sure.

# Change the access mode for our .ssh folder so that the ssh
# tools don't complain about permisisons that are too open

# chmod -R 600 /root/.ssh

# Figure out the project name from the path - note that the
# PROJECT_FOLDER path was given in the devcontainer.json
# file. The project name is the last part of the path that
# the .devcontainer lives in - ${localWorkspaceFolder}

# PROJECT_NAME="${PROJECT_FOLDER##*[\\/]}"

# If we don't already have the project repo set up, then clone it
# and run the post_clone_setup script.
#
# Also add a new remote git repo called 'host' that is actually
# the ${localWorkspaceFolder} that has been mapped to /host-workspace
# by the devcontainer.json file.

#if [ ! -d ${PROJECT_NAME} ]; then
#  git clone git@gitlab.dto.lego.com:product-technology/lpf2-wired-devices/${PROJECT_NAME}.git
#  cd ${PROJECT_NAME}
#  . ./post_clone_setup.sh
#  git remote add host /host-workspace/
#  cd ..
#fi;

#cd ${PROJECT_NAME}
#git fetch
