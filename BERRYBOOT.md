#  Cass

## Installation de 'Buildroot'

### Lectures

* [Buildroot](http://www.buildroot.org/downloads/manual/manual.html)
* [...](http://www.linuxembedded.fr/2013/02/tutorial-un-systeme-linux-embarque-operationnel-avec-buildroot/)
* [Vagrant](https://www.vagrantup.com/docs/)
* [Raspberry Pi 3 Broadcom bcm2837](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2837/README.md)
* [Alpine](http://wiki.alpinelinux.org/wiki/Developer_Documentation)
* [Docker](https://forums.docker.com/t/increase-docker-container-disk-space-on-os-x/26725/2)
* [Debian](https://www.debian.org/distrib/packages)
*

### Utilisation de 'VirtualBox' et 'Vagrant'

    #// Installer 'Buidroot'
    curl -O https://buildroot.org/downloads/Vagrantfile; vagrant up
    #// Verifier
    vagrant box list
    #// ouvrir une console
    vagrant ssh
        #// recuperer 'Berryboot' dans 'berryboot'
        git clone https://github.com/maxnet/berryboot.git
        #// se placer dans 'berryboot'
        cd berryboot
        #// tester l'installation en se préparant a attendre (quelques heures) le resultat qui se trouvera dans 'output'
        ./build-berryboot.sh device_pi2


### Utilisation de Docker

Construction d'un conteneur 'Docker' pour 'Berryboot'

    #// Changer la taille disque par defaut des conteneurs 'Docker' = '60Go'
    cd ~/Library/Containers/com.docker.docker/Data/database
    mkdir -v com.docker.driver.amd64-linux/disk
    TAILLE=60
    echo $(expr ${TAILLE} \* 512)  > com.docker.driver.amd64-linux/disk/size
    cat com.docker.driver.amd64-linux/disk/size
    git add com.docker.driver.amd64-linux/disk/size
    git commit -s -m 'New target disk size'
    ##// sauvegarder les conteneurs
    #mv -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2 ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2.save
    #// supprimer les conteneurs : ATTENTION
    rm -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2

    #// Preparer un espace de travail sur un poste muni de 'Docker'
    NO=
    DISTRIB=debian
    TAG=jessie
    CONTENEUR=${DISTRIB}${TAG}${NO}
    COMPTE=berryboot
    SRC=src
    RELEASE=2017.11
    docker container run --name ${CONTENEUR} \
            -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
            -e COMPTE=${COMPTE} \
            -e SRC=${SRC} \
            -e RELEASE=${RELEASE} \
            -v $(pwd)/${CONTENEUR}:/dist \
            -it ${DISTRIB}:${TAG} /bin/bash
        #/ afficher la version Linux
        cat /proc/version
        #// mettre a jour l'installation
        apt-get update ; apt-get -y upgrade
        #// installer le minimum necesaire ou utile
        apt-get install -y nano sudo git-core wget
        #// creer le compte 'berryboot'
        echo COMPTE=${COMPTE}
        adduser --disabled-password --disabled-login ${COMPTE}
        #// ajouter le compte 'berryboot' au groupe 'sudo'
        usermod -aG sudo ${COMPTE}
        #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
        sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
        #// verifier
        cat /etc/sudoers|grep ^%sudo
        #// installer les prerequis
        dpkg --add-architecture i386
        apt-get -q -y install libc6-i386
        apt-get -q update
        apt-get -q -y install build-essential libncurses5-dev git bzr cvs mercurial subversion autoconf gawk texinfo
        apt-get -q -y autoremove ; sudo apt-get -q -y clean
        #// passer 'berryboot'
        sudo -u ${COMPTE} SRC=${SRC} RELEASE=${RELEASE} -i
            #// recuperer les sources 'berryboot' dans 'src'
            echo SRC=${SRC}
            git clone https://github.com/maxnet/berryboot.git ${SRC}
            #// se placer dans 'src'
            cd ${SRC}

            #// recuperer 'buildroot'`
            echo RELEASE=${RELEASE}
            BUILDROOT=buildroot-${RELEASE}
            echo BUILDROOT=${BUILDROOT}
            wget https://buildroot.org/downloads/${BUILDROOT}.tar.gz
            wget https://buildroot.org/downloads/${BUILDROOT}.tar.gz.sign
            #// verifier l'empreinte 'md5'
            cat ${BUILDROOT}.tar.gz.sign|awk '/MD5:/ {print $2;}' ; md5sum ${BUILDROOT}.tar.gz|awk '{print $1;}'
            #// verifier l'empreinte 'sha1'
            cat ${BUILDROOT}.tar.gz.sign|awk '/SHA1:/ {print $2;}' ; sha1sum ${BUILDROOT}.tar.gz|awk '{print $1;}'
            #// extraire le contenu de l'archive
            tar zxfv ${BUILDROOT}.tar.gz
            sed -i -e "s/buildroot-2015.02/${BUILDROOT}/g" build-berryboot.sh
            #// tester l'installation en se préparant a attendre (quelques heures) le resultat
            #// qui si tout se passe bien se trouvera dans 'output'
            ./build-berryboot.sh device_pi2


## Utilisation de 'Buildroot'

Construction d'un conteneur 'Docker' pour 'Buildboot'

    ##// Changer la taille disque par defaut des conteneurs 'Docker' = '60Go'
    #cd ~/Library/Containers/com.docker.docker/Data/database
    #mkdir -v com.docker.driver.amd64-linux/disk
    #TAILLE=60
    #echo $(expr ${TAILLE} \* 512)  > com.docker.driver.amd64-linux/disk/size
    #cat com.docker.driver.amd64-linux/disk/size
    #git add com.docker.driver.amd64-linux/disk/size
    #git commit -s -m 'New target disk size'
    ###// sauvegarder les conteneurs
    ##mv -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2 \
    ##/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2.save
    ##// ou supprimer les conteneurs : ATTENTION
    #rm -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2

    #// Preparer un espace de travail sur un poste muni de 'Docker'
    COMPTE=buildroot
    DISTRIB=debian
    TAG=jessie
    CONTENEUR=${DISTRIB}${TAG}${COMPTE}
    #// release 'buildroot'
    RELEASE=2017.11
    #// version crosstool-ng
    VERSION=1.23.0
    docker container run --name ${CONTENEUR} --privileged \
            -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
            -e COMPTE=${COMPTE} \
            -e RELEASE=${RELEASE} \
            -e VERSION=${VERSION} \
            -v $(pwd)/${CONTENEUR}:/dist \
            -it ${DISTRIB}:${TAG} \
            /bin/bash
        #/ afficher la version Linux
        cat /proc/version
        #// mettre a jour l'installation
        apt-get update ; apt-get -y upgrade
        #// installer le minimum necesaire ou utile
        apt-get install -y nano sudo git-core wget
        #// creer le compte ${COMPTE}
        echo COMPTE=${COMPTE}
        adduser --disabled-password --disabled-login ${COMPTE}
        #// ajouter le compte 'berryboot' au groupe 'sudo'
        usermod -aG sudo ${COMPTE}
        #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
        sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
        #// verifier
        cat /etc/sudoers|grep %sudo
        #// installer les pre-requis 'crosstool-NG'
        apt-get install -y gcc gperf bison flex texinfo help2man make libncurses5-dev python-dev gawk build-essential \
        bzip2 xz-utils unzip bc cpio

    #// passer ${COMPTE}
    sudo RELEASE=${RELEASE} VERSION=${VERSION} -u ${COMPTE} -i
            #// recuperer crosstool-ng
            echo VERSION=${VERSION}
            CROSSTOOL=crosstool-ng-${VERSION}
            echo CROSSTOOL=${CROSSTOOL}
            wget http://crosstool-ng.org/download/crosstool-ng/${CROSSTOOL}.tar.bz2
            wget http://crosstool-ng.org/download/crosstool-ng/${CROSSTOOL}.tar.bz2.md5
            wget http://crosstool-ng.org/download/crosstool-ng/${CROSSTOOL}.tar.bz2.sha1
            #// verifier l'empreinte 'md5'
            md5sum -c ${CROSSTOOL}.tar.bz2.md5
            #// verifier l'empreinte 'sha1'
            sha1sum -c ${CROSSTOOL}.tar.bz2.sha1
            #// extraire le contenu de l'archive
            tar axvf ${CROSSTOOL}.tar.bz2
            #// aller dans le repertoire 'crosstool'
            cd ${CROSSTOOL}
            #// configurer 'crosstool'
            ./configure --prefix=${HOME}
            make
            #// installer 'crosstool'
            make install

            mkdir -p ${HOME}/prj/dist
            ./configure --prefix=/usr --enable-local
            make
            make DESTDIR=${HOME}/prj/dist install
            cd ${HOME}/prj
            ct-ng help

            #// configurer un projet avec 'crosstool'
            cd ${HOME}/prj
            ct-ng list-samples
            ct-ng armv8-rpi3-linux-gnueabihf
            ct-ng menuconfig
            ct-ng build

            #// retourner a la racine du COMPTE
            cd ${HOME}

            #// recuperer 'buildroot'
            echo RELEASE=${RELEASE}
            BUILDROOT=buildroot-${RELEASE}
            echo BUILDROOT=${BUILDROOT}
            wget https://buildroot.org/downloads/${BUILDROOT}.tar.gz
            wget https://buildroot.org/downloads/${BUILDROOT}.tar.gz.sign
            #// verifier l'empreinte 'md5'
            cat ${BUILDROOT}.tar.gz.sign|awk '/^MD5:/ { print $2, $3;}'|md5sum -c -
            #// verifier l'empreinte 'sha1'
            cat ${BUILDROOT}.tar.gz.sign|awk '/^SHA1:/ { print $2, $3;}'|sha1sum -c -
            #// extraire le contenu de l'archive
            tar axfv ${BUILDROOT}.tar.gz
            #// aller dans 'buildroot-...'
            cd ${BUILDROOT}
            #// creer un repertoire de travail
            mkdir -p board/proj/raspberrypi3_64/
            #// afficher l'aide
            make help
            #// afficher la liste des confugurations par defaut pour 'Raspberry Pi'
            make list-defconfigs|grep raspberry

            make raspberrypi3_64_defconfig
            make menuconfig
            make linux-menuconfig
            make linux-savedefconfig
            ID=$(ls -1 output/build|awk -F- '/^linux-/ {print $2;}')
            echo ID=${ID}
            mkdir -p board/proj/raspberrypi3_64
            cp -v output/build/linux-${ID}/defconfig board/proj/raspberrypi3_64/linux.defconfig
            make




    cd /dist/images
    IMAGE=$(ls -1 *.img)
    echo IMAGE=${IMAGE}
    FDISK="fdisk -l ${IMAGE}"
    START_1=$(${FDISK}|grep img1|awk '{ print $2; }')
    END_1=$(${FDISK}|grep img1|awk '{ print $3; }')
    SECTORS_1=$(${FDISK}|grep img1|awk '{ print $4; }')
    if [ "*" == "${START_1}" ]; then
        START_1=${END_1}
        END_1=${SECTORS_1}
        SECTORS_1=$(fdisk -l ${IMAGE}|grep img1|awk '{ print $5; }')
    fi
    echo START_1=${START_1}
    echo SECTORS_1=${SECTORS_1}
    START_2=$(fdisk -l ${IMAGE}|grep img2|awk '{ print $2; }')
    END_2=$(fdisk -l ${IMAGE}|grep img2|awk '{ print $3; }')
    SECTORS_2=$(fdisk -l ${IMAGE}|grep img2|awk '{ print $4; }')
    echo START_2=${START_2}
    echo SECTORS_2=${SECTORS_2}
    BOOT_OFFSET=$(expr 512 \* $START_1)
    BOOT_SIZELIMIT=$(expr 512 \* $SECTORS_1)
    echo BOOT_OFFSET=${BOOT_OFFSET}
    echo BOOT_SIZELIMIT=${BOOT_SIZELIMIT}
    ROOT_OFFSET=$(expr 512 \* $START_2)
    ROOT_SIZELIMIT=$(expr 512 \* $SECTORS_2)
    echo ROOT_OFFSET=${ROOT_OFFSET}
    echo ROOT_SIZELIMIT=${ROOT_SIZELIMIT}
    ROOTDIR=/dist/root
    echo ROOTDIR=${ROOTDIR}
    mkdir -pv ${ROOTDIR}
    mount -o loop,offset=${ROOT_OFFSET},sizelimit=${ROOT_SIZELIMIT} ${IMAGE} ${ROOTDIR}
    ls -la ${ROOTDIR}
    BOOTDIR=/dist/boot
    echo BOOTDIR=${BOOTDIR}
    mkdir -pv ${BOOTDIR}
    mount -o loop,offset=${BOOT_OFFSET},sizelimit=${BOOT_SIZELIMIT} ${IMAGE} ${BOOTDIR}
    ls -la ${BOOTDIR}



