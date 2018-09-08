#  Cass


## Embarqué

### Lectures

* [Livre blanc Smile](https://www.smile.eu/sites/default/files/2017-09/Linux%20embarqué_0.pdf)
* [Yocto](https://www.yoctoproject.org/docs/2.4.2/yocto-project-qs/yocto-project-qs.html)
* [...](http://git.yoctoproject.org)
* [Raspbian](https://github.com/raspberrypi/documentation/blob/master/linux/kernel/building.md)
*

    #// mettre a jour l'installation
    apt-get update ; apt-get -y upgrade
    #// installer le minimum necesaire ou utile
    apt-get install -y nano sudo git-core wget
    sudo -u ${OMPTE} -i
        sudo apt-get install -y mklibs gcc-arm-linux-gnueabi
        mkdir embarque
        cd embarque
        DIR=$(pwd)
        echo DIR=${DIR}
        git clone https://github.com/raspberrypi/linux.git
        cd linux
        RASPBIAN=rpi-4.14.y
        echo RASPBIAN=${RASPBIAN}
        BROADCOM=bcm2835
        echo BROADCOM=${BROADCOM}
        git checkout -b lb ${RASPBIAN}
        export ARCH=arm
        echo  ARCH=${ARCH}
        export CROSS_COMPILE=arm-linux-gnueabi-
        echo CROSS_COMPILE=${CROSS_COMPILE}
        make ${BROADCOM}_defconfig
        make -j 4 Image zImage
        ls -lh arch/arm/boot/*Image
        cd ..
        git clone git://busybox.net/busybox.git
        cd busybox
        make defconfig
        make
        make install CONFIG_PREFIX=${DIR}/rootfs_rpi_lb
        cd ${DIR}/rootfs_rpi_lb
        arm-linux-gnueabi-readelf -a bin/busybox | grep NEEDED
        mkdir -v lib
        ln -s $(pwd) $(pwd)/usr/arm-linux-gnueabi
        mklibs -v --ldlib /usr/arm-linux-gnueabi/lib/ld-linux.so.3 --target arm-linux-gnueabi -D -L /usr/arm-linux-gnueabi/lib/ -d lib bin/busybox
        ls -l lib

## Installer le modem 'V.TOP 56K USB Faxmodem'

    # en tant que 'root'
    #// installer les fichiers d'entete du noyau
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install raspberrypi-kernel-headers
    #// creer le repertoire de travail /home/cnxt
    mkdir -p /home/cnxt
    #// creer les liens symboliques
    ln -s /usr/src/linux-headers-$(uname -r) /usr/src/kernel-headers-$(uname -r)
    ln -s /usr/src/linux-headers-$(uname -r)/include/generated/uapi/linux/version.h /lib/modules/$(uname -r)/build/include/linux/version.h
    #// recuperer l'archive du pilote
    wget http://www.linuxant.com/drivers/dgc/archive/dgcmodem-1.13/dgcmodem-1.13.tar.gz
    #// extraire le contenu de l'archive
    tar zxvf dgcmodem-1.13.tar.gz
    #// aller dans le répertoire dgcmodem-1.13
    cd dgcmodem-1.13
    #// construire le module
    make install | tee install.log
    #// configurer le modem...
    dgcconfig
    #// supprimer le repertoire de travail /home/cnxt
    rm -rvf /home/cnxt
    
    

## Construire le noyau Raspbian

    docker container start ubuntu
    docker container exec -it ubuntu bash
    
        sudo -u pi -i
            sudo apt-get update
            sudo apt-get -y upgrade
            sudo apt-get -y install imagemagick graphviz dvipng fonts-dejavu librsvg2-bin virtualenv texlive-xetex virtualenv python-sphinx
            
            
            
            
            gcc -Wall -Wimplicit-function-declaration -I./include -I./GPL -I ./imported/include -I/usr/src/linux-headers-$(uname -r)/include -I/usr/src/linux-headers-$(uname -r)/arch/arm/include/generated -I/usr/src/linux-headers-$(uname -r)/arch/arm/include mod_dgcusbdcp.c
            
            

    
