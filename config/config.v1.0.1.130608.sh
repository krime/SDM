#!/bin/bash

COLUMNS=80
COL=$(expr ${COLUMNS} / 2)
SEP=$(printf "%${COL}s" | tr ' ' '=')

function git_conf() {
    username=$(git config --get user.name)
    useremail=$(git config --get user.email)

    echo
    echo ${SEP}
    echo Here is the GIT configurations...
    echo
    
    if [ -z ${username} ]; then
        echo Here is the user.name for GIT configuration...
        git config --global user.name $1
    else
        echo You have the user.name for GIT already! >& 2
    fi

    if [ -z ${useremail} ]; then
        echo Here is the user.email for GIT configuration...
        git config --global user.email $2
    else
        echo You have the user.email for GIT already! >& 2
    fi
    echo GIT configuration finished!
}

function ssh_conf() {
    echo
    echo ${SEP}
    echo Here is the SSH configurations...
    echo
    if [ ! -e ~/.ssh/id_rsa ]; then
        [ ! -d ~/.ssh ] && mkdir ~/.ssh
        ssh-keygen -b 4096 -t rsa -C $1 -f ~/.ssh/id_rsa -P ""
    else
        echo You have the RSA key already! >& 2
    fi
    echo SSH configuration finished!
}

function ptp_inst() {
    OS=$([ -e /etc/issue ] && cat /etc/issue | xargs -n1 | tr [:upper:] [:lower:] | head -1)
    echo
    echo ${SEP}
    echo Here is the installation of required softwares...
    echo Duiring this period, you will install the following softwares:
    echo -en "1.\tGIT\n2.\tSSH & SSH Daemon\n3.\tGCC\n4.\tOpenMPI\n5.\tJava\n"
    echo ${SEP}
    case ${OS} in
        ubuntu)
            installer='apt-get'
            openmpi='openmpi-bin'
            sshapp='openssh-{client,server}'
            sudo apt-get install systemtap
            ;;
        centos|fedora|redhat)
            installer='yum'
            openmpi='openmpi'
            sshapp='openssh'
            ;;
        *)
            installer=
            ;;
    esac
    soft=('git' 'ssh' 'sshd' 'gcc' 'g++' 'mpicc' 'java')
    for i in ${soft[*]}; do
        echo
        echo ${SEP}
        echo Checking the $i installations...
        type $i &> /dev/null
        if [ $? -eq 1 ]; then
            case $i in
                'git'|'gcc'|'g++')
                    echo You don"'"t have $i installed
                    sudo ${installer} install -y $i
                    ;;
                'ssh'|'sshd')
                    echo You don"'"t have OpenSSH Client installed
                    sudo ${installer} install -y ${sshapp}
                    ;;
                'mpicc')
                    echo You don"'"t have MPI installed
                    sudo ${installer} install -y ${openmpi}
                    ;;
                'java')
                    echo You don"'"t have Java Installed
                    case ${OS} in
                        ubuntu)
                            sudo add-apt-repository ppa:webupd8team/java
                            sudo apt-get update
                            sudo apt-get install oracle-java7-installer
                            ;;
                        centos|fedora|redhat)
                            ## JDK 64-bit ##
                            rpm -Uvh /path/to/binary/jdk-7u21-linux-x64.rpm
                            ## JRE 64-bit ##
                            rpm -Uvh /path/to/binary/jre-7u21-linux-x64.rpm

                            ## java ##
                            alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_21/jre/bin/java 20000
                            ## javaws ##
                            alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.7.0_21/jre/bin/javaws 20000

                            ## Java Browser (Mozilla) Plugin 32-bit ##
                            alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /usr/java/jdk1.7.0_21/jre/lib/i386/libnpjp2.so 20000

                            ## Java Browser (Mozilla) Plugin 64-bit ##
                            alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /usr/java/jdk1.7.0_21/jre/lib/amd64/libnpjp2.so 20000

                            ## Install javac only if you installed JDK (Java Development Kit) package ##
                            alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_21/bin/javac 20000
                            alternatives --install /usr/bin/jar jar /usr/java/jdk1.7.0_21/bin/jar 20000
                            ;;
                        *)
                            ;;
                    esac
                    ;;
                *)
                    echo I don"'"t know what is it, but you can try it
                    sudo ${installer} install $i
                    ;;
            esac
        else
            if [ $i = 'java' -a $OS = 'ubuntu' ]; then
                sudo apt-get purge openjdk*
                sudo rm /var/lib/dpkg/info/oracle-java7-installer*
                sudo apt-get purge oracle-java7-installer*
                sudo rm /etc/apt/sources.list.d/*java*
                sudo apt-get update

                sudo add-apt-repository ppa:webupd8team/java
                sudo apt-get update
                sudo apt-get install oracle-java7-installer
            fi
            echo You have installed $i already! >& 2
        fi
        sleep 3
    done
    echo All the softwares have been installed!
}

function ptp_conf() {
    echo
    echo ${SEP}
    echo Now we get into the environment configurations...
    echo
    # read -p "Please enter your name: "
    uname=$(whoami) # $REPLY
    # read -p "And your email: "
    umail=$(whoami)@$(hostname) # $REPLY

    git_conf ${uname} ${umail}
    ssh_conf ${umail}
}

function ptp_host() {
    echo
    echo ${SEP}
    echo Checking the hosts file...
    echo
    sleep 3
    hosts='localhost'
    [ $(grep -c $hosts /etc/hosts) -eq 0 ] && echo -e "127.0.0.1\tlocalhost">>/etc/hosts
    echo
    echo Finished hosts file configuration
    echo ${SEP}
}

function ptp_comm() {
    echo
    echo ${SEP}
    echo Configure the system environment...
    echo
    sleep 3
    # mkpasswd -l>/etc/passwd
    # mkgroup -l>/etc/group
    echo
    echo Finished system configuration
    echo ${SEP}
}

function ptp_main() {
    # ptp_comm
    ptp_host
    if [ $(uname -s) = "Linux" ]; then
        ptp_inst
    elif [ $(uname -o) = "Cygwin" ]; then
        echo ${SEP}
        echo Your system is Cygwin on WINDOWS_NT, please install the following
        echo softwares in your Cygwin setup panel:
        echo -en "1.\tGIT\n2.\tSSH & SSH Daemon\n3.\tGCC\n4.\tOpenMPI\n"
        echo ${SEP}
        sleep 3
    fi
    ptp_conf
}

ptp_main
