#!/bin/bash

export KAPP_HOME=$(dirname $(realpath $0))

source ${KAPP_HOME}/env.sh

export GLASSFISH_VERSION=4.1
export GLASSFISH_INSTALLE_FILE=glassfish-${GLASSFISH_VERSION}.zip
export GLASSFISH_BASE_URL="http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/${GLASSFISH_INSTALLE_FILE}"
export GLASSFISH_LOCAL_INSTALLER="/home/xtecuan/Java/installers/glassfish-${GLASSFISH_VERSION}.zip"
#export ZULU_JDK_VERSION="zulu7.56.0.11-ca-jdk7.0.352-linux_x64"
export ZULU_JDK_VERSION="zulu8.68.0.21-ca-jdk8.0.362-linux_x64"
export ZULU_LOCAL_INSTALLER="/home/xtecuan/Java/installers/${ZULU_JDK_VERSION}.tar.gz"
#export JAVA_VERSION=7
export JAVA_VERSION=8
export ZULU_JDK_URL="https://cdn.azul.com/zulu/bin/${ZULU_JDK_VERSION}.tar.gz"
export GUSER="glassfish4"
export GUSER_HOME="/home/${GUSER}"
export GUSER_TERMINAL="/bin/bash"
export TEMPORAL_DIR="/tmp"
export BASE_INSTALL_DIR="/usr/share"

sudo rm ${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}
sudo rm -rf ${BASE_INSTALL_DIR}/${GUSER}
sudo rm -rf ${BASE_INSTALL_DIR}/${ZULU_JDK_VERSION}
sudo deluser --remove-home ${GUSER}