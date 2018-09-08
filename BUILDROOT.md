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

## Création d'un conteneur 'Docker' 'Buildroot'

### Construction d'un conteneur 'Docker' pour 'Buildboot'

    #// Preparer un espace de travail sur un poste muni de 'Docker'
    COMPTE=buildroot
    DISTRIB=debian
    TAG=jessie
    CONTENEUR=${DISTRIB}${TAG}${COMPTE}
    #// release 'buildroot'
    RELEASE=2017.11
    #// repertoire associe au volume
    DIST=/dist
    docker container run --name ${CONTENEUR} --privileged \
            -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
            -e COMPTE=${COMPTE} \
            -e RELEASE=${RELEASE} \
            -e DIST=${DIST} \
            -v $(pwd)/${CONTENEUR}:${DIST} \
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
        #// installer les pre-requis
        apt-get install -y gcc gperf bison flex texinfo help2man make libncurses5-dev python-dev \
        gawk build-essential bzip2 xz-utils unzip bc cpio

        #// passer ${COMPTE}
        sudo RELEASE=${RELEASE} DIST=${DIST} -u ${COMPTE} -i
            #// recuperer 'buildroot'
            echo RELEASE=${RELEASE}
            echo DIST=${DIST}
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
            #// afficher l'aide
            make help
            #// afficher la liste des confugurations par defaut pour 'Raspberry Pi'
            make list-defconfigs|grep raspberry

            make raspberrypi3_64_defconfig
            make linux-menuconfig
            make linux-savedefconfig
            make menuconfig

            ID=$(ls -1 output/build|awk -F- '/^linux-/ {print $2;}')
            echo ID=${ID}
            #// creer un repertoire de travail
            PROJDIR=board/proj/raspberrypi3_64
            echo PROJDIR=${PROJDIR}
            mkdir -pv ${PROJDIR}
            cp -v output/build/linux-${ID}/defconfig ${PROJDIR}/linux.defconfig
            make

            #// copier l'image creee
            cp -rv output/images ${DIST}
            #// verifier l'image creee
            cd ${DIST}/images
            IMAGE=$(ls -1 *.img)
            echo IMAGE=${IMAGE}
            sudo fdisk -l ${IMAGE}
            START_1=$(sudo fdisk -l ${IMAGE}|grep img1|awk '{ print $2; }')
            SECTORS_1=$(sudo fdisk -l ${IMAGE}|grep img1|awk '{ print $3; }')
            if [ "*" == "${START_1}" ]; then
                START_1=${SECTORS_1}
                SECTORS_1=$(sudo fdisk -l ${IMAGE}|grep img1|awk '{ print $4; }')
            fi
            echo START_1=${START_1}
            echo SECTORS_1=${SECTORS_1}
            START_2=$(sudo fdisk -l ${IMAGE}|grep img2|awk '{ print $2; }')
            echo START_2=${START_2}
            SECTORS_2=$(sudo fdisk -l ${IMAGE}|grep img2|awk '{ print $3; }')
            echo SECTORS_2=${SECTORS_2}
            BOOT_OFFSET=$(expr 512 \* $START_1)
            echo BOOT_OFFSET=${BOOT_OFFSET}
            BOOT_SIZELIMIT=$(expr 512 \* $SECTORS_1)
            echo BOOT_SIZELIMIT=${BOOT_SIZELIMIT}
            ROOT_OFFSET=$(expr 512 \* $START_2)
            echo ROOT_OFFSET=${ROOT_OFFSET}
            ROOT_SIZELIMIT=$(expr 512 \* $SECTORS_2)
            echo ROOT_SIZELIMIT=${ROOT_SIZELIMIT}
            ROOTDIR=$(pwd)/mnt/root
            echo ROOTDIR=${ROOTDIR}
            mkdir -pv ${ROOTDIR}
            sudo mount -o loop,offset=${ROOT_OFFSET},sizelimit=${ROOT_SIZELIMIT} ${IMAGE} ${ROOTDIR}
            ls -la ${ROOTDIR}
            BOOTDIR=$(pwd)/mnt/boot
            echo BOOTDIR=${BOOTDIR}
            mkdir -pv ${BOOTDIR}
            sudo mount -o loop,offset=${BOOT_OFFSET},sizelimit=${BOOT_SIZELIMIT} ${IMAGE} ${BOOTDIR}
            ls -la ${BOOTDIR}
            cat ${BOOTDIR}/config.txt

            #// quitter le compte ${COMPTE}
            exit

        #// quitter le conteneur
        exit


    #// verifier l'image
    ls -la $(pwd)/${CONTENEUR}/images
