#  Cass

## Notes diverses

### Lectures

* [Markdown](https://learnxinyminutes.com/docs/fr-fr/markdown/)
* [BUILD A 64-BIT KERNEL FOR YOUR RASPBERRY PI 3](https://devsidestory.com/build-a-64-bit-kernel-for-your-raspberry-pi-3/)
* [GPIO](https://www.raspberrypi.org/documentation/usage/)
* [debootstrap](http://logan.tw/posts/2017/01/21/introduction-to-qemu-debootstrap/)
* [schroot](https://manpages.debian.org/jessie/schroot/schroot.conf.5.fr.html)
* [Debian arm64](https://people.debian.org/~stapelberg//2018/01/08/raspberry-pi-3.html)
* [PureFtpd](https://download.pureftpd.org/pub/pure-ftpd/doc/README.iPhone)
* [Developpement C](https://github.com/BrianSidebotham/arm-tutorial-rpi)
*

## Contruire un noyau arm 64 bits

    // REMARQUE : Le 'mount -o loop' dans un conteneur Docker Linux ne fonctionne pas sans l'option --privileged.

    COMPTE=pi
    DIST=ubuntu
    TAG=16.04
    #// creer le conteneur
    docker container run --name ${DIST} --privileged -e COMPTE=${COMPTE} -it ${DIST}:${TAG} /bin/bash
        #// mettre a jour le systeme
        apt-get update ; apt-get -y upgrade
        #// installer les outils
        apt-get -y install bc build-essential gcc-aarch64-linux-gnu git zip unzip wget nano sudo
        ln -sv /usr/bin/aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnugcc #// utile pour la suite...
        #// creer le compte ${COMPTE}
        echo COMPTE=${COMPTE}
        adduser --disabled-password --disabled-login ${COMPTE}
        #// ajouter le compte 'berryboot' au groupe 'sudo'
        usermod -aG sudo ${COMPTE}
        #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
        sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
        #// verifier
        cat /etc/sudoers|grep %sudo
        exit
    #// demarrer le conteneur
    docker start ${DIST} 
    #// se connecter en tant que
    docker container exec -it -u ${COMPTE} ${DIST} /bin/bash 
        cd
        // recuperer les sources du noyau Linux
        RPI=rpi-4.14.y #// changer si necessaire ou souhaite
        ARCH=arm64
        mkdir rpi_${ARCH}
        cd rpi_${ARCH}
        git clone --depth=1 -b ${RPI} https://github.com/raspberrypi/linux.git
        cd linux
        MAKE="make ARCH=${ARCH} CROSS_COMPILE=aarch64-linux-gnu- CONFIG_DEVTMPFS=y CONFIG_DEVTMPFS_MOUNT=y CONFIG_BRCMFMAC_SDIO=y"
        ${MAKE} bcmrpi3_defconfig
        ${MAKE} -j 3
        cd ..
        #// recuperer la derniere version 'raspbian' 
        wget -O raspbian.zip https://downloads.raspberrypi.org/raspbian_lite_latest
        unzip raspbian.zip
        ls -l *.img
        IMAGE=$(ls -1 *.img)
        echo IMAGE=${IMAGE}
        rm -v raspbian.zip
        cp -v ${IMAGE} $(basename ${IMAGE} .img)-${ARCH}.img
        IMAGE=$(ls -1 *-${ARCH}.img)
        echo IMAGE=${IMAGE}
        MNT=$(pwd)/rpi_${ARCH}
        FDISK="sudo fdisk -l ${IMAGE}"
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
        ROOTDIR=${MNT}/root
        echo ROOTDIR=${ROOTDIR}
        mkdir -pv ${ROOTDIR}
        MOUNT="sudo mount"
        ${MOUNT} -o loop,offset=${ROOT_OFFSET},sizelimit=${ROOT_SIZELIMIT} ${IMAGE} ${ROOTDIR}
        ls -la ${ROOTDIR}
        BOOTDIR=${MNT}/boot
        echo BOOTDIR=${BOOTDIR}
        mkdir -pv ${BOOTDIR}
        ${MOUNT} -o loop,offset=${BOOT_OFFSET},sizelimit=${BOOT_SIZELIMIT} ${IMAGE} ${BOOTDIR}
        ls -la ${BOOTDIR}
        cat ${BOOTDIR}/config.txt
        cat ${BOOTDIR}/cmdline.txt
        sudo cp -v linux/arch/arm64/boot/Image ${BOOTDIR}/kernel8.img
        sudo cp -v linux/arch/arm64/boot/dts/broadcom/bcm2837-rpi-3-b.dtb ${BOOTDIR}/
        sudo sh -c "cat >> ${BOOTDIR}/key_config.txt <<EOF
        #decode_MPG2=0x...
        #decode_WVC1=0x...
        #vcgencmd codec_enabled MPG2
        #vcgencmd codec_enabled WVC1
        EOF"
        sudo sh -c "cat >> ${BOOTDIR}/config.txt <<EOF
        
        # Enable 64bit
        arm_64bit=1
        kernel=kernel8.img
        include key_config.txt
        EOF"
        cd linux
        ${MAKE} INSTALL_MOD_PATH=${MNT} modules_install
        cd ..
        sudo umount ${BOOTDIR}
        sudo umount ${ROOTDIR}
        zip raspbian-${ARCH}.zip ${IMAGE}
        #rm -v ${IMAGE}
        exit
        
    ls -l *.img
    docker cp ${DIST}:/home/${COMPTE}/rpi_arm64/raspbian-arm64.zip .
    unzip raspbian-arm64.zip
    #// verifier
    ls -l *.img
    rm -v raspbian-arm64.zip
    #// verifier
    ls -l *-arm64.img










    
    
    
    wget http://debian.univ-lorraine.fr/debian-cd/current/arm64/iso-cd/debian-9.4.0-arm64-xfce-CD-1.iso
    wget http://debian.univ-lorraine.fr/debian-cd/current/arm64/iso-cd/SHA256SUMS
    sha256sum -c SHA256SUMS 2>&1 | grep OK
    ISODIR=$(pwd)/iso
    mkdir -pv ${ISODIR}
    sudo mount -o loop -t iso9660 debian-9.4.0-arm64-xfce-CD-1.iso ${ISODIR}
    ls -l ${ISODIR}
    
    docker container exec -it -u ${COMPTE} ${DIST} /bin/bash
        cd
        #sudo apt-get install ubuntu-keyring #// si necessaire ou souhaite
        sudo apt-get install debian-keyring
        sudo apt-get install debian-archive-keyring
        sudo apt-get install binfmt-support qemu qemu-user-static debootstrap schroot
        ARCH=arm64
        VERS=stretch
        sudo qemu-debootstrap --arch=${ARCH} ${VERS} ${ARCH}-${VERS}
        echo "[${ARCH}-${VERS}]
        description=Debian 9.4 Stretch (arm64)
        aliases=stable default
        directory=$(pwd)/${ARCH}-${VERS}
        root-groups=root
        root-users=$(whoami)
        users=$(whoami)
        type=directory" | sudo tee /etc/schroot/chroot.d/${ARCH}-${VERS}
        #schroot -c ${ARCH}-${VERS}
        SESH=$(schroot -b -c ${ARCH}-${VERS}) #// debute une session
        echo SESH=${SESH}
        schroot -r -c ${SESH} #// execute la session
            apt-get update ; apt-get -y upgrade
            groupadd -r crontab
            apt-get install -y wget git sudo
            #apt-get install -y net-tools ifupdown2 dhcpcd5
            apt-get clean
            exit
        schroot -e -c ${SESH} #// termine la session
        
        #DIR="$(pwd)/debian_${ARCH}_${VERS}"
        #echo DIR=${DIR}
        #sudo qemu-debootstrap --arch ${ARCH} ${VERS} ${DIR} http://deb.debian.org/debian/





### Compiler Swift sur la Raspberryr Pi 3 (pas possible problème de mémoire)

#### Lectures

* [Swift.org](https://github.com/apple/swift)
* [man Ubuntu](http://manpages.ubuntu.com/manpages/precise/fr/)
* [pont réseau](https://wiki.debian.org/fr/BridgeNetworkConnections)
* [...](https://www.thegeekstuff.com/2017/06/brctl-bridge/)
* [...](https://doc.ubuntu-fr.org/hostapd)
* [Wordpress](https://raspbian-france.fr/installer-wordpress-raspberry-pi-nginx/)
* [Swift](https://gist.github.com/uraimo/b74d2e8dbe7ab1a6831f4cc6eba8928c)
* [OpenVPN](https://doc.ubuntu-fr.org/openvpn)
*

    #// afficher la version Raspbian
        lsb_release -a
    #// afficher les infos sur le materiel
        cat /proc/cpuinfo
    #// aficher la configuration wifi
        cat /etc/wpa_supplicant/wpa_supplicant.conf
        #// afficher la(les) localisation(s) utilisee(s)
        cat /etc/locale.gen|grep -v '^#'
    #// flasher une image (.img -> SD)
        sudo dd bs=1M if=${IMAGE} of=${SDCARD} status=progress conv=fsync

    #// installer les paquets necessaires a la construction de Swift
        sudo apt-get install git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev autoconf libtool systemtap-sdt-dev tzdata

    #// recuperer les sources de Swift
        mkdir swift-source
        cd swift-source
        git clone https://github.com/apple/swift.git
        ./swift/utils/update-checkout --clone

    #// construire Swift
        cd swift
        utils/build-script --release-debuginfo

    #// produire la documentation et autres
        utils/build-script -h

    #// ifconfig -s
        Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
        eth0      1500      274      0      0 0           166      0      0      0 BMRU
        lo       65536       38      0      0 0            38      0      0      0 LRU
        wlan0     1500      208      0      0 0            38      0      0      0 BMRU

    #// ifconfig
        eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.120  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::4b54:13ee:24c:eecd  prefixlen 64  scopeid 0x20<link>
        ether b8:27:eb:53:2d:7e  txqueuelen 1000  (Ethernet)
        RX packets 110  bytes 23576 (23.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 89  bytes 13317 (13.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

        lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1  (Boucle locale)
        RX packets 22  bytes 1310 (1.2 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 22  bytes 1310 (1.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

        wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.121  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::2e1d:ee44:663b:2d3e  prefixlen 64  scopeid 0x20<link>
        ether b8:27:eb:06:78:2b  txqueuelen 1000  (Ethernet)
        RX packets 61  bytes 22529 (22.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 38  bytes 6515 (6.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

## Intallation de Java

    JDK=jdk-8u161-fcs-bin-b12-linux-arm32
    JINFO=.${JDK}.jinfo
    rm ${JINFO}
    touch ${JINFO}
    echo "hl rmid /usr/lib/jvm/${JDK}/jre/bin/rmid" >> ${JINFO}
    echo "hl java /usr/lib/jvm/${JDK}/jre/bin/java" >> ${JINFO}
    echo "hl keytool /usr/lib/jvm/${JDK}/jre/bin/keytool" >> ${JINFO}
    echo "hl jjs /usr/lib/jvm/${JDK}/jre/bin/jjs" >> ${JINFO}
    echo "hl pack200 /usr/lib/jvm/${JDK}/jre/bin/pack200" >> ${JINFO}
    echo "hl rmiregistry /usr/lib/jvm/${JDK}/jre/bin/rmiregistry" >> ${JINFO}
    echo "hl unpack200 /usr/lib/jvm/${JDK}/jre/bin/unpack200" >> ${JINFO}
    echo "hl orbd /usr/lib/jvm/${JDK}/jre/bin/orbd" >> ${JINFO}
    echo "hl servertool /usr/lib/jvm/${JDK}/jre/bin/servertool" >> ${JINFO}
    echo "hl tnameserv /usr/lib/jvm/${JDK}/jre/bin/tnameserv" >> ${JINFO}
    echo "hl jexec /usr/lib/jvm/${JDK}/jre/lib/jexec" >> ${JINFO}
    echo "jre policytool /usr/lib/jvm/${JDK}/jre/bin/policytool" >> ${JINFO}
    echo "jdkhl idlj /usr/lib/jvm/${JDK}/bin/idlj" >> ${JINFO}
    echo "jdkhl jdeps /usr/lib/jvm/${JDK}/bin/jdeps" >> ${JINFO}
    echo "jdkhl wsimport /usr/lib/jvm/${JDK}/bin/wsimport" >> ${JINFO}
    echo "jdkhl jinfo /usr/lib/jvm/${JDK}/bin/jinfo" >> ${JINFO}
    echo "jdkhl jsadebugd /usr/lib/jvm/${JDK}/bin/jsadebugd" >> ${JINFO}
    echo "jdkhl native2ascii /usr/lib/jvm/${JDK}/bin/native2ascii" >> ${JINFO}
    echo "jdkhl jstat /usr/lib/jvm/${JDK}/bin/jstat" >> ${JINFO}
    echo "jdkhl javac /usr/lib/jvm/${JDK}/bin/javac" >> ${JINFO}
    echo "jdkhl javah /usr/lib/jvm/${JDK}/bin/javah" >> ${JINFO}
    echo "jdkhl jps /usr/lib/jvm/${JDK}/bin/jps" >> ${JINFO}
    echo "jdkhl jstack /usr/lib/jvm/${JDK}/bin/jstack" >> ${JINFO}
    echo "jdkhl jrunscript /usr/lib/jvm/${JDK}/bin/jrunscript" >> ${JINFO}
    echo "jdkhl javadoc /usr/lib/jvm/${JDK}/bin/javadoc" >> ${JINFO}
    echo "jdkhl jhat /usr/lib/jvm/${JDK}/bin/jhat" >> ${JINFO}
    echo "jdkhl javap /usr/lib/jvm/${JDK}/bin/javap" >> ${JINFO}
    echo "jdkhl jar /usr/lib/jvm/${JDK}/bin/jar" >> ${JINFO}
    echo "jdkhl extcheck /usr/lib/jvm/${JDK}/bin/extcheck" >> ${JINFO}
    echo "jdkhl schemagen /usr/lib/jvm/${JDK}/bin/schemagen" >> ${JINFO}
    echo "jdkhl xjc /usr/lib/jvm/${JDK}/bin/xjc" >> ${JINFO}
    echo "jdkhl jarsigner /usr/lib/jvm/${JDK}/bin/jarsigner" >> ${JINFO}
    echo "jdkhl rmic /usr/lib/jvm/${JDK}/bin/rmic" >> ${JINFO}
    echo "jdkhl jstatd /usr/lib/jvm/${JDK}/bin/jstatd" >> ${JINFO}
    echo "jdkhl jmap /usr/lib/jvm/${JDK}/bin/jmap" >> ${JINFO}
    echo "jdkhl jdb /usr/lib/jvm/${JDK}/bin/jdb" >> ${JINFO}
    echo "jdkhl serialver /usr/lib/jvm/${JDK}/bin/serialver" >> ${JINFO}
    echo "jdkhl wsgen /usr/lib/jvm/${JDK}/bin/wsgen" >> ${JINFO}
    echo "jdkhl jcmd /usr/lib/jvm/${JDK}/bin/jcmd" >> ${JINFO}
    echo "jdk appletviewer /usr/lib/jvm/${JDK}/bin/appletviewe" >> ${JINFO}r
    echo "jdk jconsole /usr/lib/jvm/${JDK}/bin/jconsole" >> ${JINFO}

    cat .${JDK}.jinfo

    sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/${JDK}/bin/java 1111
    #sudo update-alternatives --config java
    sudo update-java-alternatives --list
    ## update-java-alternatives --set <jdk>
    ## update-java-alternatives  --plugin --set <jdk>


## VLC et PLEX

### Lectures
* [VLC](https://wiki.videolan.org/Documentation:Advanced_Use_of_VLC/)
* [...](https://wiki.videolan.org/Documentation:Streaming_HowTo/Command_Line_Examples/)
* [...](https://wiki.videolan.org/VLC_HowTo/Rip_a_DVD/)
* [Serveur](https://wiki.videolan.org/Documentation:Streaming_HowTo/)
* [CD-DVD](https://wiki.debian.org/fr/CDDVD)
* [PLEX](https://thepi.io/how-to-set-up-a-raspberry-pi-plex-server/)
*

    sudo apt-get install vlc-nox libdvd-pkg libdvdread4
    sudo dpkg-reconfigure libdvd-pkg
    TITRE="..."
    vlc dvdsimple:///dev/sr0#1 -vvv --color --sout "#standard{access=file,mux=ts,dst=$TITRE.mpg}" vlc://quit
    ##vlc dvdsimple:///dev/sr0#1 -vvv --color --sout "#standard{mux=ps,dst=0.0.0.0:9090,access=http}"

    #sudo apt-get install xorriso libdvd-pkg regionset lua5.3 telnet
    #xorriso -devices
    #IP=$(hostname -I | awk '{print $1;}')
    #vlc --ttl 12 -vvv --color -I telnet --telnet-password videolan --rtsp-host 0.0.0.0 --rtsp-port 1554 --vlm-conf DVD.vlm
    #nohup cvlc -Ihttp --file-logging --log-verbose=1 --logfile="vlc.log" --http-port=9090 --vlm-conf vlm.conf & echo $! > vlc.pid
    #vlc --ttl 12 -vvv --color -I telnet --telnet-password videolan --http-host 0.0.0.0 --http-port 9090 --vlm-conf DVD.vlm
    nohup cvlc -I telnet --telnet-password videolan --file-logging --log-verbose=1 --logfile="vlc.log" --rtsp-host 0.0.0.0 --rtsp-port 554 & echo $! > vlc.pid


## MacBook

### Lectures

* [changement de disque SSD](https://www.youtube.com/watch?v=gliJz9EmRq8)
* [...](https://fr.ifixit.com/Tutoriel/Remplacement+du+SSD+du+MacBook+Pro+15-Inch+Retina+mi-2015+SSD/48251)
* 

    sudo lsof -nP -i4TCP:80 | grep LISTEN
    sudo launchctl list
    sudo launchctl unload -wF /System/Library/LaunchDaemons/org.apache.httpd.plist
    
    ## Consulter les volumes Docker
    screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
    <enter>
    cd /var/lib/docker/volumes
    ls -l
    # pour sortir ^Z
    
    
