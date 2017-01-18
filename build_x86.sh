#!/bin/bash

# This script compiles libdrm and mesa for x86 platform
LOG_FILE_NAME=build.log
LOG_FILE=$(readlink -f $LOG_FILE_NAME)

function build_libdrm() {
	cd libdrm
	echo "+---------[ libdrm: autogen ]-----------+" > $LOG_FILE
	2>&1 ./autogen.sh | tee -a $LOG_FILE
	echo "+-------[ libdrm: autogen end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: autogen failed..."
		exit -1
	else
		echo "libdrm: autogen success..."
	fi

	echo "+---------[ libdrm: configure ]-----------+" >> $LOG_FILE
	2>&1 ./configure --enable-install-test-programs | tee -a $LOG_FILE
	echo "+-------[ libdrm: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: configure failed..."
		exit -1
	else
		echo "libdrm: configure success..."
	fi

	echo "+---------[ libdrm: disable optimization ]-----------+" >> $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ libdrm: disable optimization end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: disable optimization failed..."
		exit -1
	else
		echo "libdrm: disable optimization success..."
	fi
	
	echo "+---------[ libdrm: compile ]-----------+" >> $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libdrm: compile end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: compile failed..."
		exit -1
	else
		echo "libdrm: compile success..."
	fi
	cd ..
	return 0
}

function download_and_setup_llvm4_0() {
	if [ -z $(cat /etc/apt/sources.list | grep llvm-toolchain-xenial-4.0) ]; then
		sudo sh -c "wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -"
		sudo sh -c "echo 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' >> /etc/apt/sources.list"
		sudo sh -c "echo 'deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' >> /etc/apt/sources.list"
		sudo apt-get update
	fi

	local LLVM_PACKAGE_LIST=(clang-4.0 
		clang-4.0-doc 
		libclang-common-4.0-dev 
		libclang-4.0-dev 
		libclang1-4.0 
		libclang1-4.0-dbg 
		libllvm-4.0-ocaml-dev 
		libllvm4.0 
		libllvm4.0-dbg 
		lldb-4.0 
		llvm-4.0 
		llvm-4.0-dev 
		llvm-4.0-doc 
		llvm-4.0-examples 
		llvm-4.0-runtime 
		clang-format-4.0 
		python-clang-4.0 
		lldb-4.0-dev 
		liblldb-4.0-dbg
	)
	for(( i=0; i<${#LLVM_PACKAGE_LIST[@]} ; ++i )) ; do
		echo -n "Checking ["$((i+1))"/${#LLVM_PACKAGE_LIST[@]}]:{${LLVM_PACKAGE_LIST[$i]}} => "
		if [[ -z $(dpkg -l | grep ${LLVM_PACKAGE_LIST[$i]} | awk '{print $2, $3}') ]]; then
			echo -n "Installing [${LLVM_PACKAGE_LIST[$i]}]..."
			apt-get install -y ${LLVM_PACKAGE_LIST[$i]} 2>&1 > /dev/null
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

function build_libelf() {
	cd libelf
	echo "+---------[ libelf: configure ]-----------+" >> $LOG_FILE
	2>&1 ./configure --enable-debug | tee -a $LOG_FILE
	echo "+-------[ libelf: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: configure failed..."
		exit -1
	else
		echo "libelf: configure success..."
	fi

	echo "+---------[ libelf: disable optimization ]-----------+" >> $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ libelf: disable optimization end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: disable optimization failed..."
		exit -1
	else
		echo "libelf: disable optimization success..."
	fi

	echo "+---------[ libelf: compile ]-----------+" >> $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libelf: compile end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: compile failed..."
		exit -1
	else
		echo "libelf: compile success..."
	fi
	
	export PKG_CONFIG_PATH="$PWD:$PKG_CONFIG_PATH"
	echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	cd ..
	return 0
}

function build_libclc() {
	cd libclc
	echo "Checking for llvm-4.0" >> $LOG_FILE
	if [ ! -f /usr/bin/llvm-config-4.0 ]; then
		echo "LLVM 4.0 not found..."
		return -1
	fi

	echo "+---------[ libclc: configure ]-----------+" >> $LOG_FILE
	2>&1 ./configure.py --with-llvm-config=/usr/bin/llvm-config-4.0 | tee -a $LOG_FILE
	echo "+-------[ libclc: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: configure failed..."
		exit -1
	else
		echo "libclc: configure success..."
	fi

	echo "+---------[ libclc: disable optimization ]-----------+" >> $LOG_FILE
	sed -ie 's/\ -O2//g' Makefile
	echo "+-------[ libclc: disable optimization end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: disable optimization failed..."
		exit -1
	else
		echo "libclc: disable optimization success..."
	fi

	echo "+---------[ libclc: compile ]-----------+" >> $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libclc: compile end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: compile failed..."
		exit -1
	else
		echo "libclc: compile success..."
	fi

	export PKG_CONFIG_PATH="$PWD:$PKG_CONFIG_PATH"
	echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	cd ..
	return 0
}

function build_mesa_with_openCL() {
	cd mesa
	echo "+---------[ mesa: autogen ]-----------+" >> $LOG_FILE
	2>&1 ./autogen.sh | tee -a $LOG_FILE
	echo "+-------[ mesa: autogen end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: autogen failed..."
		exit -1
	else
		echo "mesa: autogen success..."
	fi

	echo "+---------[ mesa: configure ]-----------+" >> $LOG_FILE
	#2>&1 ./configure --enable-opencl --with-gallium-drivers=i915,ilo,nouveau,r300,r600,radeonsi,freedreno,svga,swrast,vc4,virgl --with-llvm-prefix=$(/usr/bin/llvm-config-4.0 --prefix) | tee -a $LOG_FILE
	2>&1 ./configure --enable-opencl --with-llvm-prefix=$(/usr/bin/llvm-config-4.0 --prefix) | tee -a $LOG_FILE
	echo "+-------[ mesa: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: configure failed..."
		exit -1
	else
		echo "mesa: configure success..."
	fi

	echo "+---------[ mesa: disable optimization ]-----------+" >> $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ mesa: disable optimization end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: disable optimization failed..."
		exit -1
	else
		echo "mesa: disable optimization success..."
	fi

	echo "+---------[ mesa: compile ]-----------+" >> $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ mesa: compile end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: compile failed..."
		exit -1
	else
		echo "mesa: compile success..."
	fi

	cd ..
	return 0
}

function main() {
	echo "Logging build output in $LOG_FILE"
	build_libdrm
	if [ $? -ne 0 ]; then
		echo "Building libdrm_failed..."
		exit -1
	fi

	build_libelf
	if [ $? -ne 0 ]; then
		echo "Building libelf failed..."
		exit -1
	fi

	build_libclc
	if [ $? -ne 0 ]; then
		echo "Building libclc failed..."
		exit -1
	fi

	build_mesa_with_openCL
	if [ $? -ne 0 ]; then
		echo "Building mesa with OpenCL failed..."
		exit -1
	fi

	return 0
}

# Call main
main
 

