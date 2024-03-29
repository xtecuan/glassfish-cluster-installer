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
export BASE_INSTALL_DIR="/opt"
export GLASSFISH_DOMAIN="spiCDC"

setupGlassfishUser() {
    response=$(getent passwd ${GUSER})
    if [ "${response}" = "" ]
    then
        sudo useradd -m -d ${GUSER_HOME} -U -s ${GUSER_TERMINAL} ${GUSER}
        echo "${GUSER} created with HOME ${GUSER_HOME}"
        sudo usermod -a -G sudo ${GUSER}
    else
        echo "User $GUSER already exists"
    fi
}


downloadGlassfishInstaller() {

    if [ -n "$1" -a -f "$1" ]
    then
        rm -v ${TEMPORAL_DIR}/glassfish-${GLASSFISH_VERSION}.zip
        cp -v $1 ${TEMPORAL_DIR}/
    else
        if [ -f ${TEMPORAL_DIR}/${GLASSFISH_INSTALLE_FILE} ]
        then
            echo "${TEMPORAL_DIR}/${GLASSFISH_INSTALLE_FILE} already exists"
        else
            wget $GLASSFISH_BASE_URL -O ${TEMPORAL_DIR}/$GLASSFISH_INSTALLE_FILE
        fi
    fi
}

downloadZuluJDKInstaller() {
    if [ -n "$1" -a -f "$1" ]
    then
        rm -v ${TEMPORAL_DIR}/${ZULU_JDK_VERSION}.tar.gz
        cp -v $1 ${TEMPORAL_DIR}/
    else
        if [ -f "${TEMPORAL_DIR}/${ZULU_JDK_VERSION}.tar.gz" ]
        then
            echo "${TEMPORAL_DIR}/${ZULU_JDK_VERSION}.tar.gz already exists"
        else
            wget ${ZULU_JDK_URL} -O ${TEMPORAL_DIR}/${ZULU_JDK_VERSION}.tar.gz
        fi
    fi
}



installGlassfish(){
    if [ -d "${BASE_INSTALL_DIR}/${GUSER}" ]
    then
        sudo rm -rfv ${BASE_INSTALL_DIR}/${GUSER}
    else
        sudo unzip ${TEMPORAL_DIR}/glassfish-${GLASSFISH_VERSION}.zip -d ${BASE_INSTALL_DIR}/
        sudo sh -c "echo \"AS_JAVA=${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}\" >> ${BASE_INSTALL_DIR}/${GUSER}/glassfish/config/asenv.conf"
        sudo chown -R ${GUSER}: ${BASE_INSTALL_DIR}/${GUSER}

        echo "Glassfish Installer ready to use!"
    fi
}

configureGlassfishUser(){
    sudo sh -c "echo \"export JAVA_HOME=${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}\" >> ${GUSER_HOME}/.bashrc"
    sudo sh -c "echo \"export GLASSFISH_HOME=${BASE_INSTALL_DIR}/${GUSER}\" >> ${GUSER_HOME}/.bashrc"
    mystring='export PATH=\$JAVA_HOME/bin:\$GLASSFISH_HOME/bin:\$PATH'
    sudo sh -c "echo \"${mystring}\" >> ${GUSER_HOME}/.bashrc"
    sudo passwd ${GUSER}
}

configureGlassfishDomain(){
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin list-domains"
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin delete-domain domain1"
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin create-domain --savelogin $GLASSFISH_DOMAIN "
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin start-domain $GLASSFISH_DOMAIN"
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin enable-secure-admin"
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin stop-domain $GLASSFISH_DOMAIN"
    sudo -u ${GUSER} sh -c "${BASE_INSTALL_DIR}/${GUSER}/bin/asadmin start-domain $GLASSFISH_DOMAIN"
}


installZuluJDK(){
    if [ -d "${BASE_INSTALL_DIR}/${ZULU_JDK_VERSION}" ]
    then
        if [ -L "${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}" ]
        then
            rm -v ${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}
        fi
        sudo rm -rfv ${BASE_INSTALL_DIR}/${ZULU_JDK_VERSION}
    else
        sudo tar -xvzf ${TEMPORAL_DIR}/${ZULU_JDK_VERSION}.tar.gz -C ${BASE_INSTALL_DIR}/
        sudo ln -s ${BASE_INSTALL_DIR}/${ZULU_JDK_VERSION}   ${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}
        sudo chown -R ${GUSER}: ${BASE_INSTALL_DIR}/${ZULU_JDK_VERSION}
        sudo chown  ${GUSER}: ${BASE_INSTALL_DIR}/jdk${JAVA_VERSION}
        echo "Zulu Installer ready to use!"
    fi
}

if [ -n "$1" ]
then
    downloadGlassfishInstaller "$1"
else
    downloadGlassfishInstaller
fi
if [ -n "$2" ]
then
    downloadZuluJDKInstaller "$2"
else
    downloadZuluJDKInstaller
fi


setupGlassfishUser
installZuluJDK
installGlassfish
configureGlassfishUser
configureGlassfishDomain
