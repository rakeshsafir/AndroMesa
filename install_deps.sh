#!/bin/bash

echo "+-----------[ Mesa Compilation Deps Installer ]------------+"

PACKAGE_LIST=(autoconf
libtool
bison
flex
python-pip
libpthread-stubs0-dev
x11proto-gl-dev
libdrm-dev
x11proto-dri2-dev
x11proto-dri3-dev
x11proto-present-dev
libxcb1-dev
libxcb-dri3-dev
libxcb-present-dev
libxcb-sync-dev
libxshmfence-dev
libxext-dev
libxdamage-dev
libx11-xcb-dev
libxcb-glx0-dev
libxcb-dri2-0-dev
libomxil-bellagio-dev
llvm
xutils-dev
libpciaccess-dev
)


function install_python_sub_packages() {
	pip install mako
}

function install_packages() {
	
	for(( i=0; i<${#PACKAGE_LIST[@]} ; ++i )) ; do
		echo -n "Checking ["$((i+1))"/${#PACKAGE_LIST[@]}]:{${PACKAGE_LIST[$i]}} => "
		if [[ -z $(dpkg -l | grep ${PACKAGE_LIST[$i]} | awk '{print $2, $3}') ]]; then
			echo -n "Installing [${PACKAGE_LIST[$i]}]..."
			apt-get install -y ${PACKAGE_LIST[$i]} 2>&1 > /dev/null
			if [[ $? -eq 0 ]]; then
				echo "Success..."
			else
				echo "Failed..."
			fi
		else
			echo "Installed..."
		fi
	done
}

function check_root() {
	if [[ $(whoami) != "root" ]]; then
		echo "This script needs to be run with root privileges..."
		exit
	fi
}

function main() {
	check_root
	install_packages
}

main


