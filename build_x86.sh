#!/bin/bash

# This script compiles libdrm and mesa for x86 platform

PREFIX_DIR="$(readlink -f .)"/build
LOG_FILE=$PREFIX_DIR/build.log
echo "PREFIX_DIR=[$PREFIX_DIR] log=[$LOG_FILE]"

function build_libdrm() {
	cd libdrm
	echo "+---------[ libdrm: autogen ]-----------+" >> $LOG_FILE
	2>&1 ./autogen.sh | tee -a $LOG_FILE
	echo "+-------[ libdrm: autogen end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: autogen failed..."
		return -1
	else
		echo "libdrm: autogen success..."
	fi

	echo "+---------[ libdrm: configure ]-----------+" >> $LOG_FILE
	2>&1 ./configure --prefix=$PREFIX_DIR --enable-install-test-programs | tee -a $LOG_FILE
	echo "+-------[ libdrm: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: configure failed..."
		return -1
	else
		echo "libdrm: configure success..."
	fi

	echo "+---------[ libdrm: disable optimization ]-----------+" >> $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ libdrm: disable optimization end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: disable optimization failed..."
		return -1
	else
		echo "libdrm: disable optimization success..."
	fi
	
	echo "+---------[ libdrm: compile ]-----------+" >> $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libdrm: compile end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: compile failed..."
		return -1
	else
		echo "libdrm: compile success..."
	fi

	echo "+---------[ libdrm: install ]-----------+" >> $LOG_FILE
	2>&1 make install | tee -a $LOG_FILE
	echo "+-------[ libdrm: install end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libdrm: install failed..."
		return -1
	else
		echo "libdrm: install success..."
	fi
	cd ..
	return 0
}

function download_and_setup_llvm4_0() {
	if [ -z $(cat /etc/apt/sources.list | grep llvm-toolchain-xenial-4.0) ]; then
		sudo sh -c "wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -"
		sudo sh -c "echo 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' >> /etc/apt/sources.list"
		sudo sh -c "echo 'deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' >> /etc/apt/sources.list"
		sudo sh -c "apt-get update"
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
			sudo sh -c "apt-get install -y ${LLVM_PACKAGE_LIST[$i]} 2>&1 > /dev/null"
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
	2>&1 ./configure --prefix=$PREFIX_DIR --enable-debug | tee -a $LOG_FILE
	echo "+-------[ libelf: configure end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: configure failed..."
		return -1
	else
		echo "libelf: configure success..."
	fi

	echo "+---------[ libelf: disable optimization ]-----------+" | tee -a $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ libelf: disable optimization end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: disable optimization failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libelf: disable optimization success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ libelf: compile ]-----------+" | tee -a $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libelf: compile end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: compile failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libelf: compile success..." | tee -a $LOG_FILE
	fi
	
	echo "+---------[ libelf: install ]-----------+" >> $LOG_FILE
	2>&1 make install | tee -a $LOG_FILE
	echo "+-------[ libelf: install end ]---------+" >> $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libelf: install failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libelf: install success..." | tee -a $LOG_FILE
	fi

	cd ..
	return 0
}

function build_libclc() {
	cd libclc
	echo "Checking for llvm-4.0" >> $LOG_FILE
	if [ ! -f /usr/bin/llvm-config-4.0 ]; then
		echo "LLVM 4.0 not found...Installing..." | tee -a $LOG_FILE
		download_and_setup_llvm4_0
	fi

	echo "+---------[ libclc: configure ]-----------+" | tee -a $LOG_FILE
	2>&1 ./configure.py --prefix=$PREFIX_DIR --with-llvm-config=/usr/bin/llvm-config-4.0 | tee -a $LOG_FILE
	echo "+-------[ libclc: configure end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: configure failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libclc: configure success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ libclc: disable optimization ]-----------+" | tee -a $LOG_FILE
	sed -ie 's/\ -O2//g' Makefile
	echo "+-------[ libclc: disable optimization end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: disable optimization failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libclc: disable optimization success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ libclc: compile ]-----------+" | tee -a $LOG_FILE
	2>&1 make | tee -a $LOG_FILE
	echo "+-------[ libclc: compile end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: compile failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libclc: compile success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ libclc: install ]-----------+" | tee -a $LOG_FILE
	2>&1 make install | tee -a $LOG_FILE
	echo "+-------[ libclc: install end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "libclc: install failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "libclc: install success..." | tee -a $LOG_FILE
	fi

	cd ..
	return 0
}

function build_mesa_with_openCL() {
	cd mesa
	echo "+---------[ mesa: autogen ]-----------+" | tee -a $LOG_FILE
	2>&1 ./autogen.sh  --prefix="$PREFIX_DIR" --with-sysroot="$PREFIX_DIR" --enable-opencl --enable-opencl-icd --with-dri-drivers="" --with-gallium-drivers=i915,nouveau,r300,r600,radeonsi,svga,swrast --with-llvm-prefix=$(/usr/bin/llvm-config-4.0 --prefix) CFLAGS="-g -I$PREFIX_DIR/include" CXXFLAGS="-g -I$PREFIX_DIR/include" LDFLAGS="-Wl,--export-dynamic" | tee -a $LOG_FILE
	echo "+-------[ mesa: autogen end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: autogen failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "mesa: autogen success..." | tee -a $LOG_FILE
	fi

#	echo "+---------[ mesa: configure ]-----------+" | tee -a $LOG_FILE
#	2>&1 ./configure --prefix=$PREFIX_DIR --with-sysroot=$PREFIX_DIR --enable-opencl --enable-opencl-icd --with-dri-drivers="" --with-gallium-drivers=i915,nouveau,r300,r600,radeonsi,svga,swrast --with-llvm-prefix=$(/usr/bin/llvm-config-4.0 --prefix) | tee -a $LOG_FILE
#	echo "+-------[ mesa: configure end ]---------+" | tee -a $LOG_FILE
#	if [ $? -ne 0 ]; then
#		echo "mesa: configure failed..." | tee -a $LOG_FILE
#		exit -1
#	else
#		echo "mesa: configure success..." | tee -a $LOG_FILE
#	fi

	echo "+---------[ mesa: disable optimization ]-----------+" | tee -a $LOG_FILE
	sed -ie 's/\ -O2//g' config.status
	2>&1 ./config.status | tee -a $LOG_FILE
	echo "+-------[ mesa: disable optimization end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: disable optimization failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "mesa: disable optimization success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ mesa: compile ]-----------+" | tee -a $LOG_FILE
	2>&1 make -j16 | tee -a $LOG_FILE
	echo "+-------[ mesa: compile end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: compile failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "mesa: compile success..." | tee -a $LOG_FILE
	fi

	echo "+---------[ mesa: install ]-----------+" | tee -a $LOG_FILE
	2>&1 make install | tee -a $LOG_FILE
	echo "+-------[ mesa: install end ]---------+" | tee -a $LOG_FILE
	if [ $? -ne 0 ]; then
		echo "mesa: install failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "mesa: install success..." | tee -a $LOG_FILE
	fi

	cd ..
	return 0
}

function main() {
	echo "Logging build output in $LOG_FILE"
	echo "+---------[ Build Start: $(date +%Y-%m-%d:%H:%M:%S) ]-----------+" | tee -a $LOG_FILE

#	build_libdrm
#	if [ $? -ne 0 ]; then
#		echo "Building libdrm_failed..." | tee -a $LOG_FILE
#		return -1
#	fi

#	build_libelf
#	if [ $? -ne 0 ]; then
#		echo "Building libelf failed..." | tee -a $LOG_FILE
#		return -1
#	fi

#	build_libclc
#	if [ $? -ne 0 ]; then
#		echo "Building libclc failed..." | tee -a $LOG_FILE
#		return -1
#	fi

	build_mesa_with_openCL
	if [ $? -ne 0 ]; then
		echo "Building mesa with OpenCL failed..." | tee -a $LOG_FILE
		return -1
	else
		echo "Building mesa with OpenCL success..." | tee -a $LOG_FILE			
	fi
	
	echo "+---------[ Build End: $(date +%Y-%m-%d:%H:%M:%S) ]-----------+" | tee -a $LOG_FILE
	return ret
}

# Call main
mkdir -p $PREFIX_DIR
main
 

