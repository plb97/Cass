#  Cass

## Lectures

* [Raspberry Pi](https://github.com/raspberrypi/linux)
* [Raspberry Lite](https://www.raspberrypi.org/forums/viewtopic.php?t=133691)
* [Raspbian sur un disque USB](https://soozx.fr/raspberry-pi-deplacer-raspbian-disque-cle-usb/)
* [Berryboot](https://raspbian-france.fr/comment-installer-plusieurs-os-sur-la-raspberry-pi-avec-berryboot/)
* [Berryboot image](http://www.berryterminal.com/doku.php/berryboot)
* [...](https://robert.penz.name/73/kpartx-a-tool-for-mounting-partitions-within-an-image-file/)
* [Berryboot OS images](https://sourceforge.net/projects/berryboot/files/)
* [BerryTerminal](http://www.berryterminal.com/doku.php/berryboot/headless_installation)
* [...](http://www.berryterminal.com/doku.php/start)
* [Debian](https://wiki.debian.org/RaspberryPi3)
* [Docker](https://docs.docker.com/install/linux/docker-ce/debian/#upgrade-docker-after-using-the-convenience-script)
*


## Activation IPv4 pour la carte Wifi 'wlan0'

Si 'ifconfig wlan0' ne fait pas apparaitre d'adresse IPv4, en tant que 'root'  ( sudo -i ) :

il faut crérer le fichier '/etc/network/interfaces.d/wlan0'

    CARTE=wlan0
    echo "auto ${CARTE}
        allow-hotplug ${CARTE}" | sed -e 's|^        ||g' > /etc/network/interfaces.d/${CARTE}
        
puis relancer le service 'dhcpcd'

    service dhcpcd restart

et enfin vérifier le résultat

    ifconfig ${CARTE} 2>/dev/null|grep ' inet '|awk '{ print $2; }'
    ip -4 a show ${CARTE} 2>/dev/null|grep inet|awk '{ print $2; }'|awk -F/ '{ print $1; }'

## Installation du systeme sur un disque USB externe

    #// se connecter comme utilisateur 'pi' et configurer le systeme
    sudo raspi-config
    sudo reboot
    
    #// se connecter comme utilisateur 'pi' et passer 'root'
    sudo -i
    #// mettre a jour le systeme
    apt-get update ; apt-get -y upgrade
    ADMIN=admin
    #// creer un compte '${ADMIN}'
    useradd -m -d /${ADMIN} -U -G sudo -s /bin/bash -r ${ADMIN}
    #// definir un mot de passe pour le compte '${ADMIN}'
    passwd ${ADMIN}
        ...
    #// autoriser les membres du groupe 'sudo' a utiliser 'sudo' sans mot de passe
    sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
    #// verifier
    cat /etc/sudoers|grep ^%sudo
    #// desactiver le compte 'pi' (facultatif)
    usermod -L pi
    #// quitter 'root'
    exit
    #// se deconnecter
    exit

    #// se connecter comme utilisateur 'admin' et passer 'root'
    sudo -i
    #// lister tous les disques et trouver le disque USB externe
    fdisk -l
    DISQUE=/dev/sda
    #// verifier en listant les partitions du disque '${DISQUE}'
    fdisk -l ${DISQUE}
    #// choisir la partition a monter
    PART=${DISQUE}1
    #// montage du disque USB externe sur /mnt
    mount ${PART} /mnt
    #// arreter certains services si necessaire...
    #// copier le contenu de la racine '/'
    rsync -avx / /mnt
    #// sauvegarder 'cmdline.txt'
    cp -v /boot/cmdline.txt /boot/orig.cmdline.txt
    #// remplacer la partition racine
    cat /boot/cmdline.txt
    sed -i -e "s|\( root=\S\+\)| root=${PART}|" /boot/cmdline.txt
    cat /boot/cmdline.txt
    #// sauvegarder 'config.txt'
    cp -v /boot/config.txt /boot/orig.config.txt
    #// ajouter 'program_usb_timeout=1' a la fin du fuchier 'config.txt'    
    echo 'program_usb_timeout=1' >> /boot/config.txt 
    cat /boot/config.txt
    #// recuperer l'ID et le type de la partition (facultatif)
    eval $(blkid ${PART}|awk -F: '{print $2;}')
    echo ${UUID}
    echo ${TYPE}
    #// sauvegarder le fichier '/mnt/etc/fstab'
    cp -v /mnt/etc/fstab /mnt/etc/orig.fstab
    #// remplacer le disque racine
    #sed -i -e "s|^[^#]\(\S\+\)\s\+/\s\+\(\S\+\)|UUID=${UUID} / ${TYPE}|" /mnt/etc/fstab
    cat /mnt/etc/fstab
    sed -i -e "s|^[^#]\(\S\+\)\s\+/\s\+\(\S\+\)|${PART} / ${TYPE}|" /mnt/etc/fstab
    cat /mnt/etc/fstab
    # redemarrer
    reboot
  

## Installer 'Docker'

    #// se connecter avec le compte 'admin' et passer 'root'
    sudo -i
    #// creer le compte 'docker'
    COMPTE=docker
    echo COMPTE=${COMPTE}
    useradd -m -U -s /bin/bash -G sudo ${COMPTE}
    #// bloquer le compte 'docker'
    usermod -L ${COMPTE}
    
    #// quitter 'root'
    #// passer 'docker'
    sudo -u docker -i
    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm -v get-docker.sh
    #// verifier
    docker container run hello-world
    docker container run -it ubuntu bash
    #// lister les conteneurs actifs
    docker container ls
    #// lister tous les conteneurs
    docker container ls -a
    #// lister les images
    docker image ls
    #// supprimer les images 'ubuntu' et 'hello-world'
    docker image rm -f ubuntu hello-world
    docker image ls
    #// quitter 'docker'
    exit
    #// terminer la session 'admin'
    exit
    








    
    
## Berryboot

    #// installer les packages 'kpartx' 'squashfs-tools'
    sudo apt-get install kpartx squashfs-tools unzip
    #// creer un repertoire de travail
    RASPBIAN=raspbian_lite_latest // changer si necessaire ou souhaite
    mkdir ${RASPBIAN}
    cd ${RASPBIAN}
    wget -O ${RASPBIAN}.zip https://downloads.raspberrypi.org/${RASPBIAN}
    unzip ${RASPBIAN}.zip
    IMAGE=$(ls -1 *.img)
    echo IMAGE=${IMAGE}
    fdisk -l ${IMAGE}
    sudo kpartx -l ${IMAGE}
    sudo kpartx -av ${IMAGE}
    #// creer un point de montage
    MNT=./mnt
    mkdir ${MNT}
    #// effectuer le montage
    PART2=$(sudo kpartx -av ${IMAGE}|grep loop\.p2|awk '{ print $3; }')
    echo PART2=${PART2}
    sudo mount /dev/mapper/${PART2} ${MNT}
    #// verifier le montage
    cat ${MNT}/etc/fstab
    sudo sed -i 's/^PARTUUID.*ext4/#\0/g' ${MNT}/etc/fstab
    sudo rm -fv ${MNT}/etc/console-setup/cached_UTF-8_del.kmap.gz
    IMAGE192=${IMAGE}192
    echo IMAGE192=${IMAGE192}
    sudo mksquashfs ${MNT} ${IMAGE192} -comp lzo -e lib/modules
    #// verifier la presence de la nouvelle image
    ls -l ${IMAGE192}
    sudo umount ${MNT}
    rm -rv ${MNT}
    sudo kpartx -d ${IMAGE}

## Montage automatique disques USB ou DVD

### Lectures

* [Automount](https://ddumont.wordpress.com/2015/09/27/how-to-automount-optical-media-on-debian-linux-for-kodi/)
* [...](https://www.freedesktop.org/software/systemd/man/systemd.mount.html)
* [...](http://carnetdevol.shost.ca/wordpress/monter-partitions-systemd-unites-de-type-mount/)
*
Après avoir installé l'image Raspbian Lite souhaitée (par exemple '2017-11-29-raspbian-stretch-lite.img') sur la Raspberry Pi 3, effectué la configurartion nécessaire, banché un lecteur CD-DVD et un ou plusieurs disques USB, se connecter comme utilistateur 'pi'.

Formater le disque USB si nécessaire.

    #// passer 'root'
    sudo -i
        #// mettre a jour l'installation
        apt-get update
        apt-get upgrade
        apt-get dist-upgrade
        
        #// lister les disques
        sudo dmesg
        #// creer une partition sur le disque
        #// s'il est neuf et non encore partionne
        #// formater la partion en 'ext3'
        DISK=/dev/sda
        fdisk ${DISK}
            n
            ...
            w
        PART=${DISK}1
        mkfs.ext3 ${PART}

Lorsque le disque est prêt, poursuivre l'installation.

    #// passer 'root'
    sudo -i
        #// sauvegarder '/etc/fstab'
        cp -v /etc/fstab /etc/fstab.origin
        #// voir la configuration disque
        blkid
        lsblk
        #// creer le point de montage pour le lecteur CD-DVD
        mkdir -p /media/udf0
        #// creer un lien sympoblique 'cdrom' (facultatif)
        ln -s /media/udf0 /media/cdrom
        #// dans l'hypothese ou il y a au plus un seul lecteur CD-DVD
        #// ajouter la ligne suivante dans '/etc/fstab'
        echo "/dev/sr0 /media/udf0 auto defaults,nofail,x-systemd.automount 0 2" >> /etc/fstab
        #// dans l'hypothese ou il y a zero, un ou plusieurs disques
        for PARTUUID in "$(blkid|grep -v mmc|grep -v udf|grep PARTUUID=|awk -F"PARTUUID=" '{print $2;}'|awk -F\" '{print $2;}')"
        do
            echo PARTUUID=${PARTUUID}
            #// creer le point de montage pour le disque
            mkdir -pv /media/disk/${PARTUUID}
            #// ajouter la ligne suivante dans '/etc/fstab'
            echo "PARTUUID=${PARTUUID} /media/disk/${PARTUUID} auto defaults,nofail,x-systemd.automount 0 2" >> /etc/fstab
        done
        #// verifier le resultat
        cat /etc/fstab
        #// recharger '/etc/fstab'
        systemctl daemon-reload
        #// monter le lecteur CD-DVD et le ou les disques
        mount -a
        #// verifier
        ls -l /media/cdrom/
        ls -l /media/disk/${PARTUUID}/
        #// voir les unites generees par 'systemd'
        systemctl cat media-udf0.mount
        systemctl cat media-udf0.automount
        systemctl cat media-disk-*.mount
        systemctl cat media-disk-*.automount

        #// redemarrer
        reboot


## Fichier 'swap'

### Lectures

* [Swapfile](https://wiki.debian.org/fr/Swap)
* 

    cat /etc/dphys-swapfile
    sudo sed -i -e 's|^CONF_SWAPSIZE=100$|CONF_SWAPSIZE=1024 #100|g' /etc/dphys-swapfile 
    cat /etc/dphys-swapfile
    sudo dphys-swapfile swapoff
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
    sudo swapon


### Lister les services actifs

    systemctl list-unit-files --state=enabled
