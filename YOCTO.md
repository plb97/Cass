#  Cass


## Yocto

### Lectures

* [Livre blanc Smile](https://www.smile.eu/sites/default/files/2017-09/Linux%20embarqué_0.pdf)
* [Yocto](https://www.yoctoproject.org/docs/2.4.2/yocto-project-qs/yocto-project-qs.html)
* [...](http://git.yoctoproject.org)
* [...](http://git.yoctoproject.org/cgit/cgit.cgi)
* [...](http://git.yoctoproject.org/cgit/cgit.cgi/meta-raspberrypi/tree/docs/layer-contents.md)
* [...](http://git.yoctoproject.org/cgit/cgit.cgi/meta-raspberrypi/tree/README.md)
*

### Construction d'un conteneur 'Docker' pour 'Buildboot'

    #// Preparer un espace de travail sur un poste muni de 'Docker'
    COMPTE=yocto
    DISTRIB=debian
    TAG=stretch
    CONTENEUR=${DISTRIB}${TAG}${COMPTE}
    #// release
    RELEASE=rocko
    #// repertoire associe au volume
    DIST=/dist
    LANG=en_US.UTF-8
    #            -e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
    docker container run --name ${CONTENEUR} --privileged \
            -e COMPTE=${COMPTE} \
            -e LANG=${LANG} \
            -e RELEASE=${RELEASE} \
            -e DIST=${DIST} \
            -v $(pwd)/${CONTENEUR}:${DIST} \
            -p 8000:8000 \
            -it ${DISTRIB}:${TAG} \
            /bin/bash
        #/ afficher la version Linux
        cat /proc/version
        #// mettre a jour l'installation
        apt-get update ; apt-get -y upgrade
        #// installer les 'locales'
        apt-get install -y locales
        cat /etc/locale.gen|grep ${LANG}
        cp -v /etc/locale.gen /etc/locale.gen.origin
        sed -i -e 's|^# en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|' /etc/locale.gen
        cat /etc/locale.gen|grep ${LANG}
        locale-gen
        ## locales 152. en_US.UTF-8
        ## locales 226. fr_FR.UTF-8
        ##dpkg-reconfigure locales
        ##...
        #// installer le minimum necesaire ou utile
        apt-get install -y nano sudo git-core wget net-tools
        echo COMPTE=${COMPTE}
        echo "\n\n\n\n\n\n"|adduser --disabled-password --disabled-login ${COMPTE}
        #...
        #// ajouter le compte 'berryboot' au groupe 'sudo'
        usermod -aG sudo ${COMPTE}
        #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
        sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
        #// verifier
        cat /etc/sudoers|grep %sudo
        #// passer ${COMPTE}
        sudo LANG=${LANG} RELEASE=${RELEASE} DIST=${DIST} -u ${COMPTE} -i
            #// installer les pre-requis
            sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
            build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
            xz-utils debianutils iputils-ping
            #// Installer Yocto
            git clone -b ${RELEASE} git://git.yoctoproject.org/poky.git
            #// aller dans le repertoire 'poky'
            cd poky
            #// installer Toaster
            pip3 install --user -r bitbake/toaster-requirements.txt
            pip3 list installed --local
            ##source ./oe-init-build-env qemux86-build
            ##bitbake core-image-minimal
            ##cd
            ##cd poky
            #git clone -b ${RELEASE} git://git.openembedded.org/openembedded-core
            #cd ${HOME}/poky/openembedded-core
            #git clone -b ${RELEASE} git://git.openembedded.org/meta-openembedded
            git clone -b ${RELEASE} git://git.yoctoproject.org/meta-raspberrypi
            #source ./oe-init-build-env rpi3-64-build
            source ./oe-init-build-env
            #// lancer 'Toaster'
            source toaster start webport=0.0.0.0:8000
            netstat -pae
            #// creer un super utilisateur
            ../bitbake/lib/toaster/manage.py createsuperuser




            bitbake-layers add-layer "${HOME}/poky/meta-raspberrypi"
            ##sed -i -e 's!^  "$!  /home/yocto/poky/meta-raspberrypi \\!' conf/bblayers.conf
            ##echo '  "' >> conf/bblayers.conf
            #// verifier
            cat conf/bblayers.conf
            ##sed -i -e 's/^MACHINE ??= "qemux86"/MACHINE ??= "raspberrypi3-64"/' conf/local.conf
            echo 'MACHINE = "raspberrypi3-64"' >> conf/local.conf
            echo 'PACKAGE_CLASSES = "package_deb"' >> conf/local.conf
            #// ajouter la suppression de l'espace de travail
            echo 'INHERIT += "rm_work"' >> conf/local.conf
            #// verifier
            cat conf/local.conf
            bitbake rpi-hwup-image




