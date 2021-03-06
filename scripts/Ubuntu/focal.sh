#!/bin/bash
#shellcheck disable=SC2086,SC2015,SC2164

function add_releasespecific_tools() {
    # 32bit support
    tools_array+=( "libcurl4:i386" "libcurl4-gnutls-dev" )
    # HWE kernel
    tools_array+=( "linux-generic-hwe-18.04" )
}

function configure_mercurial_repository() {
    echo "[INFO] Running configure_mercurial_repository on Ubuntu 20.04...skipped"
}

function install_powershell() {
    echo "[INFO] Install PowerShell on Ubuntu 20.04..."
    local TMP_DIR
    TMP_DIR=$(mktemp -d)
    pushd -- "${TMP_DIR}"
    local PWSH_INSTALL_DIR=/opt/microsoft/powershell/7-focal
    local TAR_NAME=powershell-7.0.0-linux-x64.tar.gz

    #download package
    curl -fsSL -O "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/${TAR_NAME}"

    # install
    mkdir -p ${PWSH_INSTALL_DIR}
    tar -zxf "${TAR_NAME}" -C ${PWSH_INSTALL_DIR}
    ln -s ${PWSH_INSTALL_DIR}/pwsh /usr/bin/pwsh

    configure_powershell

    popd &&
    rm -rf "${TMP_DIR}"
    log_version pwsh --version
}

function config_dotnet_repository() {
    curl -fsSL -O https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb &&
    dpkg -i packages-microsoft-prod.deb &&
    apt-get -y -qq update ||
        { echo "[ERROR] Cannot download and install Microsoft's APT source." 1>&2; return 10; }
}

function prepare_dotnet_packages() {
    SDK_VERSIONS=( "2.1" "2.2" "3.0" "3.1" )
    dotnet_packages "dotnet-sdk-" SDK_VERSIONS[@]

    declare RUNTIME_VERSIONS=( "2.1" "2.2" )
    dotnet_packages "dotnet-runtime-" RUNTIME_VERSIONS[@]
}

function install_outdated_dotnets() {
    echo "[INFO] Running install_outdated_dotnets on Ubuntu 20.04...skipped"
}

function configure_rabbitmq_repositories() {
    echo "[INFO] Running configure_rabbitmq_repositories..."

    add-apt-repository "deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang" ||
        { echo "[ERROR] Cannot add rabbitmq-erlang repository to APT sources." 1>&2; return 10; }

    add-apt-repository "deb https://dl.bintray.com/rabbitmq/debian bionic main" ||
        { echo "[ERROR] Cannot add rabbitmq repository to APT sources." 1>&2; return 10; }
}

function configure_docker_repository() {
    echo "[INFO] Running configure_docker_repository on Ubuntu 20.04..."

    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" ||
        { echo "[ERROR] Cannot add Docker repository to APT sources." 1>&2; return 10; }    
}

function configure_firefox_repository() {
    echo "[INFO] Running configure_firefox_repository on Ubuntu 20.04..."
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6DCF7707EBC211F
    add-apt-repository "deb [ arch=amd64 ] http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu bionic main"
    apt-get -y update
}

function install_mongodb() {
    echo "[INFO] Running install_mongodb..."
    apt install -yqq mongodb ||
        { echo "[ERROR] Cannot install mongodb." 1>&2; return 10; }

    log_version dpkg -l mongodb
}

function install_jdks_from_repository() {
    echo "[INFO] Running install_jdks_from_repository..."
    add-apt-repository -y ppa:openjdk-r/ppa
    apt-get -y -qq update && {
        apt-get -y -q install --no-install-recommends openjdk-8-jdk
    } ||
        { echo "[ERROR] Cannot install JDKs." 1>&2; return 10; }
    update-java-alternatives --set java-1.8.0-openjdk-amd64

    # there is no support for openJDK 7 in Ubuntu 18.04
    install_jdk 7 https://download.java.net/openjdk/jdk7u75/ri/openjdk-7u75-b13-linux-x64-18_dec_2014.tar.gz

    # hold openjdk 11 package if it was installed
    # newer version of openjdk will be installed later on
    if dpkg -l openjdk-11-jre-headless; then
        echo "openjdk-11-jre-headless hold" | dpkg --set-selections
    fi
}

function install_sqlserver() {
    echo "[INFO] Running install_sqlserver..."
    echo "[WARNING] SQL Server is not supported on Ubuntu 20.04 yet"
}

function configure_sqlserver() {
    echo "[INFO] Running configure_sqlserver..."
    echo "[WARNING] SQL Server is not supported on Ubuntu 20.04 yet"
}

function disable_sqlserver() {
    echo "[INFO] Running disable_sqlserver..."
    echo "[WARNING] SQL Server is not supported on Ubuntu 20.04 yet"
}

function fix_sqlserver() {
    echo "[INFO] Running fix_sqlserver on Ubuntu 20.04...skipped"
}

function configure_mono_repository () {
    echo "[INFO] Running install_mono on Ubuntu 20.04..."
    add-apt-repository "deb http://download.mono-project.com/repo/ubuntu preview-${OS_CODENAME} main" ||
        { echo "[ERROR] Cannot add Mono repository to APT sources." 1>&2; return 10; }
}

function configure_azurecli_repository() {
    echo "[INFO] Running configure_azurecli_repository..."
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" > /etc/apt/sources.list.d/azure-cli.list
}
