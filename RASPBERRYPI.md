#  Cass

## Lectures

* [Raspberry Pi](https://github.com/raspberrypi/linux)
* [Raspberry Lite](https://www.raspberrypi.org/forums/viewtopic.php?t=133691)
* [Rasperry Bureau](https://dadarevue.com/ajouter-gui-raspbian-lite/)
* [Raspbian sur un disque USB](https://soozx.fr/raspberry-pi-deplacer-raspbian-disque-cle-usb/)
* [Berryboot](https://raspbian-france.fr/comment-installer-plusieurs-os-sur-la-raspberry-pi-avec-berryboot/)
* [Berryboot image](http://www.berryterminal.com/doku.php/berryboot)
* [...](https://robert.penz.name/73/kpartx-a-tool-for-mounting-partitions-within-an-image-file/)
* [Berryboot OS images](https://sourceforge.net/projects/berryboot/files/)
* [BerryTerminal](http://www.berryterminal.com/doku.php/berryboot/headless_installation)
* [...](http://www.berryterminal.com/doku.php/start)
* [Debian](https://wiki.debian.org/RaspberryPi)
* [Docker](https://docs.docker.com/install/linux/docker-ce/debian/#upgrade-docker-after-using-the-convenience-script)
* [Tensorflow](http://math.mad.free.fr/depot/numpy/essai.html)
* [Numpy](http://cs231n.github.io/python-numpy-tutorial/)
* [Jupyter](https://www.digitalocean.com/community/tutorials/how-to-set-up-jupyter-notebook-with-python-3-on-debian-9)
* [Anaconda](https://www.anaconda.com/distribution/)
* [jplephem](https://pypi.org/project/jplephem/)
* [skyfield](https://rhodesmill.org/skyfield/)
* [banques audio](https://www.saturax.fr/blog/liste-meilleures-banques-de-son-gratuit-libre-de-droit/)
* [scikit-learn](https://scikit-learn.org/)
* [Stats](https://www.math.univ-toulouse.fr/~besse/Wikistat/pdf/)
* [...](https://github.com/wikistat/)
* [Unbound](https://techarea.fr/creer-resolveur-dns-unbound-debian/?cn-reloaded=1)
* [...](https://sizeof.cat/post/unbound-on-macos/)
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

    #// passer 'root'
    sudo -i
    #// sauvegarder 'cmdline.txt'
    cp -v /boot/cmdline.txt /boot/cmdline.txt.origin
    #// sauvegarder 'config.txt'
    cp -v /boot/config.txt /boot/config.txt.origin
    #// sauvegarder le fichier '/etc/fstab'
    cp -v /etc/fstab /etc/fstab.origin
    #
    #// lister tous les disques et trouver le disque USB externe
    fdisk -l
    DISQUE=/dev/sda
    #// verifier en listant les partitions du disque '${DISQUE}'
    fdisk -l ${DISQUE}
    blkid ${DISQUE}
    #// choisir la partition à monter
    PART=${DISQUE}1
    #// noter l'ID de la partition
    blkid ${PART}
    # formater la partition si nécessaire
    mkfs.ext4 ${PART}
    #// monter le disque USB externe sur /mnt
    mount ${PART} /mnt
    #// arreter certains services si necessaire...
    #// copier le contenu de la racine '/'
    rsync -avx --exclude 'boot' --exclude 'tmp' --exclude 'mnt' / /mnt/
    #// recuperer l'ID et le type de la partition (facultatif)
    eval $(blkid ${PART}|awk -F': ' '{print $2;}')
    echo UUID=${UUID}
    echo TYPE=${TYPE}
    echo PARTUUID=${PARTUUID}
    #// remplacer la partition racine
    cat /boot/cmdline.txt |tee /boot/cmdline.txt.usb
    sed -i -e "s|\( root=\S\+\)| root=PARTUUID=${PARTUUID}|" /boot/cmdline.txt.usb
    cat /boot/cmdline.txt.usb
    #// ajouter 'program_usb_timeout=1' a la fin du fichier 'config.txt'
    cat /boot/config.txt|tee /boot/config.txt.usb 
    echo 'program_usb_timeout=1' >> /boot/config.txt.usb 
    cat /boot/config.txt.usb
    #// remplacer le disque racine
    cat /etc/fstab|tee /etc/fstab.usb
    #// conserver la ligne concernant la racine /
    LINE=$(grep '^[^#]\(\S\+\)\s\+/\s\+\(\S\+\)' /etc/fstab.usb)
    echo LINE=$LINE
    sed -i -e "s|^[^#]\(\S\+\)\s\+/\s\+\(\S\+\)|PARTUUID=${PARTUUID} / ${TYPE}|" /etc/fstab.usb
    #// ajouter la ligne avec l'ancienne racine montée sur /mnt
    echo $LINE|sed -e 's| / | /mnt |' | tee -a /etc/fstab.usb
    
    # sauvegarder l'ancien fichier fstab
    cat /etc/fstab.origin|tee /mnt/etc/fstab.origin
    # recopier le nouveau fichier fstab
    cat /etc/fstab.usb|tee /mnt/etc/fstab.usb
    # préparer le redémarrage
    cp -v /boot/cmdline.txt.usb /boot/cmdline.txt
    cp -v /boot/config.txt.usb /boot/config.txt
    cp -v /mnt/etc/fstab.usb /mnt/etc/fstab
    #
    # redemarrer
    #
    reboot

    #// pour revenir en arrière au cas où
    #
    sudo cp -v /boot/cmdline.txt.origin /boot/cmdline.txt
    sudo cp -v /boot/config.txt.origin /boot/config.txt
    sudo cp -v /mnt/etc/fstab.origin /mnt/etc/fstab
    sudo reboot
  

## Installer 'Docker'

### Lecture

* [Instructions](https://docs.docker.com/install/linux/docker-ce/debian/)
* 

    #// se connecter avec le compte 'admin' et passer 'root'
    sudo -i
    #// creer le compte 'docker'
    COMPTE=docker
    echo COMPTE=${COMPTE}
    useradd -m -U -s /bin/bash -G sudo ${COMPTE}
    #// bloquer le compte 'docker'
    usermod -L ${COMPTE}
    #// autoriser 'docker' à utiliser 'sudo' sans mot-de-passe
    echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_docker-nopasswd
    cat /etc/sudoers.d/010_docker-nopasswd
    
    #// quitter 'root'
    exit
    #// passer 'docker'
    sudo -u docker -i
    #curl -fsSL get.docker.com -o get-docker.sh
    #sudo sh get-docker.sh
    #rm -v get-docker.sh

    #Installer à partir du dépôt officiel

    #// ATTENTION : supprimer 'aufs' qui pose des problèmes
    sudo apt purge aufs-dev aufs-tools aufs-dkms
    sudo apt-get autoremove
    #// supprimer la version précédente
    sudo apt-get remove docker docker-engine docker.io containerd runc
    #// preparer l'installation
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    #sudo add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable"
    echo "deb [arch=armhf] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable"|sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-get update
    #// installer docker-ce
    sudo apt-get install --no-install-recommends docker-ce
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
    #// terminer la session 'root' ou 'admin'
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

## Freenove

### Lectures

[Raspberry Pi ...](https://mespotesgeek.fr/fr/installation-et-configuration-dun-raspberry/)
[Raspberry PI ...](https://mespotesgeek.fr/fr/controle-dun-dispositif-basse-tension-via-raspberry-pi/)
[Raspberry PI ...](https://mespotesgeek.fr/fr/variation-de-puissance-electrique-via-raspberry/)
[Raspberry Pi ...](https://mespotesgeek.fr/fr/wifi-sur-raspberry/)
[Raspberry Pi ...](https://mespotesgeek.fr/fr/un-vpn-personnel-pour-un-service-commercial/)
[Raspberry Pi ...](https://mespotesgeek.fr/fr/web-radio-reveil-sur-raspberry/)
[Raspberry Pi ...](https://projects.drogon.net/raspberry-pi/)
[Raspberry Pi Tutoriel](https://projects.raspberrypi.org/en/projects/physical-computing)
[Raspberry Pi Gpiozero](https://gpiozero.readthedocs.io/en/stable/index.html)
[Paspberry Pi Python](https://deusyss.developpez.com/tutoriels/RaspberryPi/PythonEtLeGpio/)
[raspberry-gpio-python](https://sourceforge.net/p/raspberry-gpio-python/wiki/Examples/)
[python3](https://docs.python.org/fr/3.5/)
[GPIO](http://www.pibits.net/category/code)
[Python GPIO...](https://deusyss.developpez.com/tutoriels/RaspberryPi/PythonEtLeGpio/)
[Processing](https://pi.processing.org/download/)
[KiCad](http://docs.kicad-pcb.org/4.0.7/fr/getting_started_in_kicad.html)
[KiCad](https://www.youtube.com/watch?v=yPX33hmjWS8&frags=pl%2Cwn)
[KiCad](https://www.youtube.com/watch?v=U0zn2dS4Jac&frags=pl%2Cwn)
[RFID](https://www.gotronic.fr/pj2-sbc-rfid-rc522-fr-1439.pdf)
[...](http://espace-raspberry-francais.fr/Composants/Module-RFID-RC522-Raspberry-Francais/)
[...](http://wg8.de/wg8n1496_17n3613_Ballot_FCD14443-3.pdf)
[...](https://github.com/ljos/MFRC522/blob/master/examples/auth_read_write/auth_read_write.ino)
[...](https://github.com/paulvha/rfid-rc522)
[MFRC522](https://github.com/mxgxw/MFRC522-python/blob/master/MFRC522.py)
[...](https://www.youtube.com/watch?v=UTe3eYCj6vU&frags=pl%2Cwn)
[...](https://www.youtube.com/watch?v=Lwjwg36DfWo&frags=pl%2Cwn)
[...](https://www.astuces-pratiques.fr/electronique/la-resistance-limitation-de-courant)
[...](https://www.astuces-pratiques.fr/electronique/montage-de-led-en-serie-et-resistance)
[Blender](https://www.poleblender.fr/tuto-blender/modélisation/escalier-hélicoïdal-1er-partie/)
[3D](https://www.gamoover.net/Forums/index.php?topic=34386.0)
[Electronique](http://electroniqueamateur.blogspot.com/2016/01/explorons-les-transistors-bipolaires.html)
[...](http://www.epsic.ch/cours/electronique/techn99/elnthcomp/CMPTHINTRO.html)
[...](http://www.epsic.ch/cours/electronique/techn99/elncomp/CMPINTRO.html)
[...](http://www.lps.ens.fr/~ebrunet/PhyStat.pdf)
[...](https://www.astuces-pratiques.fr/electronique/regulateur-de-tension-lm317-montages)
[Cours d'électronique : Le transistor MOSFET. Partie 1 : Présentation. Caractéristiques. Equations](https://www.youtube.com/watch?v=qrDnXA6F1Ls)
[Cours d'électronique : Le transistor MOSFET. Partie 2 : Comprendre son fonctionnement interne](https://www.youtube.com/watch?v=W2qqGayp2-8)
[Cours d'électronique : Transistor bipolaire #1 : Présentation. Caractéristiques. Equations](https://www.youtube.com/watch?v=KTnwiGqjSr8&frags=wn)
[Cours d'électronique : Transistor bipolaire #2 : Utilisation en tout ou rien (saturé-bloqué)](https://www.youtube.com/watch?v=9wAIhLf20ts&frags=pl%2Cwn)
[KiCad 5, l'essentiel. Partie 1 : Dessiner le schéma électronique](https://www.youtube.com/watch?v=C9EWrKw9Qz8)
[KiCad 5, l'essentiel. Partie 2 : Créer une empreintes](https://www.youtube.com/watch?v=U0zn2dS4Jac)
[KiCad 5, l'essentiel. Partie 3 : Choisir et associer les empreintes aux composants](https://www.youtube.com/watch?v=nUZ9vKbhyaY)
[KiCad 5, l'essentiel. Partie 4 : Importer la netliste et placer les composants](https://www.youtube.com/watch?v=udtxzxKdEQ8)
[KiCad 5, l'essentiel. Partie 5 : Spécifier les règles de conception et Router](https://www.youtube.com/watch?v=-PCrFnJr3mg)
[KiCad 5, l'essentiel. Partie 6 : Prendre en compte une modification du schéma dans PCBnew](https://www.youtube.com/watch?v=QrjaMSA-i5g)
[KiCad 5, l'essentiel. Partie 7 : Préparer la sérigraphie et finaliser la couche de fabrication](https://www.youtube.com/watch?v=svRIJMCNm-U)
[KiCad : Objet MySensors. 6 - Associer empreintes - Créer netliste](https://www.youtube.com/watch?v=EWAGePBuAzk&frags=pl%2Cwn)
[Simulation avec KiCad 5 #1 : Réponse transitoire et fréquentielle d'un circuit RC](https://www.youtube.com/watch?v=aehIYiFCrQU)
[Simulation avec KiCad 5 #2 : Timer Programmable LM555](https://www.youtube.com/watch?v=8GJplg6eB4Y&frags=pl%2Cwn)
[Simulation avec KiCad 5 #3 : Générateur carré-triangle à base d'amplificateurs opérationnels](https://www.youtube.com/watch?v=_bmjYRhTpWU)
[Simulation avec KiCad 5 #4 : Créer un modèle SPICE (ici un relais) et l'utiliser](https://www.youtube.com/watch?v=icGv5x1yPYs)
[Eric PERONNIN](http://geii.eu/index.php)




### Installation de 'Gpiozero'

    sudo apt-get update
    sudo apt-get install -y python-gpiozero python3-gpiozero

### Utilisation de 'Remote GPIO'

    #// installer 'pigpio' sur la machine cible (Raspberry Pi)
    sudo apt install pigpio
    #// activer les connexions distantes (apres avoir activer 'Remote GPIO' avec raspi-config)
    sudo systemctl enable pigpiod
    sudo systemctl start pigpiod

    #// installer pigpio sur la machine distante
    sudo pip3 install gpiozero pigpio
    #// utiliser pigpio sur la machine distante
    PIGPIO_ADDR=<IP Raspberry Pi> GPIOZERO_PIN_FACTORY=pigpio python3 <scripte>.py

### Installation de 'Raspberry-gpio-python'

    sudo apt-get update
    sudo apt-get install -y python-rpi.gpio python3-rpi.gpio
   
### Installation Freenove Ultimate Starter Kit for Raspberry Pi
    
    git clone https://github.com/freenove/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi

### Installation des librairies KiCad de Digikey 

    git clone https://github.com/digikey/digikey-kicad-library.git

### Installation des empreintes 'liftoff-sr'
    
    git clone https://github.com/liftoff-sr/pretty_footprints.git


## Tensorflow

    sudo apt-get install libatlas-base-dev
    sudo pip3 install tensorflow
    sudo pip3 install numpy

## Traitement du signal audio

    %matplotlib inline
    import librosa
    data, sampling_rate = librosa.load('audio/stephane-mallat.2018-01-11-18-00-00-a-fr.mp3')
    import matplotlib.pyplot as plt
    plt.figure(figsize=(12, 4))
    import librosa.display as dsp
    dsp.waveplot(data[:500], sr=sampling_rate)
    import numpy as np
    tf = librosa.stft(data[:10000])
    print(np.abs(tf[:100]))
    D = librosa.amplitude_to_db(np.abs(tf), ref=np.max)
    plt.subplot(1, 1, 1)
    dsp.specshow(D, y_axis='linear')
    plt.colorbar(format='%+2.0f dB')
    plt.title('Linear-frequency power spectrogram')

# Unbound

    sudo apt update
    #sudo apt list --upgradable
    #sudo apt upgrade
    
    # installer 'unbound' et 'unbound-host'
    sudo apt install unbound unbound-host
    sudo wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /var/lib/unbound/root.hints
    
    # Facultatif : recuprer la liste noire des hotes StevenBlack
    (curl --silent https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts | grep '^0\.0\.0\.0' | sort) | awk '{print "local-zone: \""$2"\" refuse"}' > zone-block-general.conf
    sudo mv -v zone-block-general.conf /var/lib/unbound/zone-block-general.conf
    sudo chown unbound:unbound /var/lib/unbound/zone-block-general.conf
    
    # configurer 'unbound'
    # creer un fichier /etc/unbound/unbound.conf.d/<xxxx>.conf contenant (par exemple) :
        server:
        verbosity: 3
        
        interface: 127.0.0.1
        #access-control: 127.0.0.0/8 allow 
        
        interface: ::1
        #access-control: ::/8 allow
        
        port: 53
        do-ip4: yes
        do-ip6: yes
        do-udp: yes
        do-tcp: no
        ## autorise n’importe quel utilisateur en ipv4 !
        access-control: 0.0.0.0/0 allow
        ## autorise n’importe quel utilisateur en ipv6 !
        access-control: ::/0 allow
        ## voir fichier '/etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf'
        #auto-trust-anchor-file: "/var/lib/unbound/root.key"
        root-hints: "/var/lib/unbound/root.hints"
        hide-identity: yes
        hide-version: yes
        harden-glue: yes
        harden-dnssec-stripped: yes
        use-caps-for-id: yes
        cache-min-ttl: 3600
        cache-max-ttl: 86400
        prefetch: yes
        num-threads: 6
        msg-cache-slabs: 16
        rrset-cache-slabs: 16
        infra-cache-slabs: 16
        key-cache-slabs: 16
        rrset-cache-size: 256m
        msg-cache-size: 128m
        so-rcvbuf: 1m
        unwanted-reply-threshold: 10000
        do-not-query-localhost: yes
        val-clean-additional: yes
        use-syslog: yes
        logfile: /var/log/unbound.log
        
        # additional blocklist (Steven Black hosts file, read above)
        include: /var/lib/unbound/zone-block-general.conf

        
    # verifier la configuration
    unbound-checkconf /etc/unbound/unbound.conf
    
    # (re)lancer le service
    sudo systemctl restart unbound

# Python Jupyter

## Lectures

* [Installation](https://www.digitalocean.com/community/tutorials/how-to-set-up-jupyter-notebook-with-python-3-on-debian-9)
* [Configuration](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html)
* [Extensions](https://ndres.me/post/best-jupyter-notebook-extensions/)
* [Nodejs](https://www.instructables.com/id/Install-Nodejs-and-Npm-on-Raspberry-Pi/)
* [lsb_release](http://www.linuxfromscratch.org/blfs/view/svn/postlfs/lsb-release.html)
* [Python3.7](https://www.ramoonus.nl/2018/06/30/installing-python-3-7-on-raspberry-pi/)
* [...](https://zestedesavoir.com/tutoriels/954/notions-de-python-avancees/2-functions/3-decorators/)
* [JplEphem](https://pypi.org/project/jplephem/)
* 

### Installation

    sudo apt update
    sudo apt install python3-pip python3-dev
    
    sudo -H pip3 install --upgrade pip
    
### Sans Virtualenv

    sudo -H apt remove python3-zmq python3-terminado
    sudo -H pip3 install --upgrade ipywidgets nbconvert
    
    sudo -H pip3 install --upgrade notebook
    
### Avec Virtualenv
    
    sudo -H pip3 install virtualenv
    PROJDIR=myprojectdir
    PROJENV=myprojectenv
    
    mkdir ~/${PROJDIR}
    cd ~/${PROJDIR}
    
    virtualenv ${PROJENV}
    source ${PROJENV}/bin/activate
    
    pip install jupyter
    jupyter notebook

### Tunnel ssh

    # copier la clé publique sur le <serveur distant>
    ssh pi@<serveur distant> "mkdir ~/.ssh"
    cat ~/.ssh/id_rsa.pub | ssh pi@<serveur distant> "cat - >> ~/.ssh/authorized_keys"

    ssh -L 8899:localhost:9999 pi@<serveur distant>
    
    # copier un fichier sur le <serveur distant>
    scp -p <fichiers> pi@<serveur distant>:<repertoire>[/<autre nom fichier>]
    # copier un repertoire sur le <serveur distant>
    scp -p -r <repertoire> pi@<serveur distant>:<repertoire>[/<autre nom repertoire>]


### Configuration

    jupyter notebook --generate-config
    jupyter notebook password
      
    nano ~/.jupyter/jupyter_notebook_config.py
        c.NotebookApp.allow_password_change = True
        c.NotebookApp.allow_remote_access = True
        c.NotebookApp.ip = '*'
        c.NotebookApp.local_hostnames = ['*']
        c.NotebookApp.port = 9999

    
    ### Jupyterlab
    
    # installation nodejs
    
    wget https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-armv7l.tar.xz
    tar xvf node-v10.16.0-linux-armv7l.tar.xz
    cd node-v10.16.0-linux-armv7l
    sudo -H cp -R * /usr/local/
    rm -r node-v10.16.0-linux-armv7l*

    node -v
    npm -v

    # installation Jupyterlab
    
    sudo -H pip3 install jupyterlab

### Intallation Jupyter avec Python3.7

    # Installation de 'lsb_release'
    wget https://downloads.sourceforge.net/lsb/lsb-release-1.4.tar.gz
    tar zxvf lsb-release-1.4.tar.gz
    cd lsb-release-1.4
    make
    sudo make install
    cd ..
    rm -rv lsb-release-1.4*
    
    # Installation setuptools
    wget https://files.pythonhosted.org/packages/1d/64/a18a487b4391a05b9c7f938b94a16d80305bf0369c6b0b9509e86165e1d3/setuptools-41.0.1.zip
    unzip setuptools-41.0.1.zip
    cd setuptools-41.0.1
    sodo python3 setup.py install
    cd ..
    rm rv setuptools-41.0.1* 
    
    # Installation de Python3.x
    sudo -H apt-get update
    sudo -H apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev  libopenblas-dev libxslt1-dev texlive-xetex
    #sudo -H apt install libatlas-base-dev liblapack-dev

    #pyversv=3.7.4
    #pyver=3[.]7
    # REMARQUE : Python 3.7 et Jupyterlab 1.0 ne semblent pas etre compatibles
    pyversv=3.6.9
    pyver=3[.]6
    wget https://www.python.org/ftp/python/${pyversv}/Python-${pyversv}.tgz
    tar xzf Python-${pyversv}.tgz
    cd Python-${pyversv}
    ./configure --prefix=/usr/local/opt/python-${pyversv} --enable-optimizations
    make -j 4

    sudo make altinstall
    
    cd ..
    #rm -rvf Python-${pyversv}*
    
    for f in $(ls -1 /usr/local/opt/python-${pyversv}/bin/)
    do
      g=$(echo $f | sed -e "s/${pyver}/3/")
      sudo -H ln -s -f /usr/local/opt/python-${pyversv}/bin/$f /usr/bin/$f
      sudo -H ln -s -f /usr/bin/$f /usr/bin/$g
    done
    sudo -H python3 -m pip install pip setuptools --upgrade
    
    # Installation de 'Jupyter'
    
    sudo -H pip3 install jupyter
    for f in $(ls -1 /usr/local/opt/python-${pyversv}/bin/ | grep -v "${pyver}" | grep -v 'pip')
    do
      echo $f
      sudo -H ln -s -f /usr/local/opt/python-${pyversv}/bin/$f /usr/bin/$f
    done

    #sudo -H pip3 install cython
    #sudo -H pip2 install pyzmq --install-option="--zmq=bundled"
    #for f in $(ls -1 /usr/local/opt/python-${pyversv}/bin/)
    #do
    #    sudo -H ln -s -f /usr/local/opt/python-${pyversv}/bin/$f /usr/bin/$f
    #done
    
    ## Intallation de 'nbextensions'
    ##
    #for p in nbextensions jupyter_contrib_nbextensions
    #do
    #  #sudo -H pip3 install -U $p
    #  pip3 install -U $p --user
    #done
    #python3 -m jupyter contrib-nbextension install --user
    
    # Intallation de 'jupterlab'
    #
    for p in jupyterlab jupyterlab_latex jupyter_nbextensions_configurator
    do
      sudo -H pip3 install -U $p
    done
    python3 -m jupyter serverextension enable --user jupyterlab_latex
    
    python3 -m jupyter serverextension list --user
    
    # Installation scipy et autres
    ##sudo -H apt-get install python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose
    
    # Installation de paquets complementaires
    for p in numpy matplotlib pandas skyfield Cython
    do
      sudo -H pip3 install -U $p
    done
    
    # Installation du paquet scipy
    sudo -H apt-get install libatlas-base-dev python3-dev libopenblas-dev gfortran
    # attendre un certain temps...
    sudo -H pip3 install -U scipy
    
    # compilation tres tres longue (100% CPU)...
    # echo -n "" > paquets.list
    #echo "sympy" >> paquets.list
    #echo "pandas" >> paquets.list
    #echo "matplotlib" >> paquets.list
    #echo "xlrd" >> paquets.list
    #echo "skyfield" >> paquets.list
    #echo "scipy" >> paquets.list
    #sudo -H pip3 install -r paquets.list
    
    
## Gestionnaire de fenêtres

### Lightdm

#### Installation 
    sudo apt-get install lightdm
    sudo reboot

#### Activation
    sudo dpkg-reconfigure lightdm

#### Visualisation de la configuration
    /usr/sbin/lightdm --show-config
    
#### Redémarrage
    sudo restart lightdm

### Pixel

#### Installation
    sudo apt-get install -y raspberrypi-ui-mods rpi-chromium-mods
    sudo reboot


## Migrer vers Raspbian/Buster

[Référence : ](https://www.raspberrypi.org/blog/buster-the-new-version-of-raspbian/)

1. In the files **/etc/apt/sources.list** and **/etc/apt/sources.list.d/raspi.list**, change every use of the word “stretch” to “buster”.
2. In a terminal,

        sudo apt update

    and then

        sudo apt dist-upgrade

3. Wait for the upgrade to complete, answering ‘yes’ to any prompt. There may also be a point at which the install pauses while a page of information is shown on the screen – hold the ‘space’ key to scroll through all of this and then hit ‘q’ to continue.
4. The update will take anywhere from half an hour to several hours, depending on your network speed. When it completes, reboot your Raspberry Pi.
5. When the Pi has rebooted, launch ‘Appearance Settings’ from the main menu, go to the ‘Defaults’ tab, and press whichever ‘Set Defaults’ button is appropriate for your screen size in order to load the new UI theme.
6. Buster will have installed several new applications which we do not support. To remove these, open a terminal window and

        sudo apt purge timidity lxmusic gnome-disk-utility deluge-gtk evince wicd wicd-gtk clipit usermode gucharmap gnome-system-tools pavucontrol

    We hope that Buster gives a little hint of shiny newness for those of you who aren’t able to get your hands on a Raspberry Pi 4 immediately! As ever, your feedback is welcome – please leave your comments below.


### scripte

    for f in $(find /etc/apt -type f -name "*.list")
    do 
      sudo cp -v $f $f.origin
      sudo sed -i -e 's|stretch|buster|g' $f
    done
    
    dpkg -l | awk '/^rc/ { print $2 }'
    apt purge $(dpkg -l | awk '/^rc/ { print $2 }')
    deborphan --guess-*
    

## Initialisation d'une installation à partir d'une autre (exemple)

### Création du scripte ~/bin/initrpi

    #!/bin/bash

    SERVEUR="$1"

    #ssh-keygen -f "~/.ssh/known_hosts" -R "${SERVEUR}"

    # créer les répertoires distants
    ssh pi@${SERVEUR} "mkdir ~/.ssh; mkdir ~/bin; mkdir ~/.jupyter; mkdir ~/myprojectdir"

    # copier la clé publique sur le <serveur distant>
    cat ~/.ssh/id_rsa.pub | ssh pi@${SERVEUR} "cat - >> ~/.ssh/authorized_keys"

    # copier un fichier sur le <serveur distant>
    scp -p ~/.ssh/id_rsa* pi@${SERVEUR}:~/.ssh
    scp -p ~/bin/* pi@${SERVEUR}:~/bin
    scp -p ~/.jupyter/jupyter_* pi@${SERVEUR}:~/.jupyter
    scp -p ~/.jupyter/pycert.pem pi@${SERVEUR}:~/.jupyter
    scp -p ~/.jupyter/pykey.key pi@${SERVEUR}:~/.jupyter

    # copier un repertoire sur le <serveur distant>
    scp -p -r myprojectdir pi@${SERVEUR}:~/


## Avahi (Bonjour)

### Lectures
* [Configuration](https://elinux.org/RPi_Advanced_Setup)
* [Bonjour](https://www.journaldulapin.com/2015/08/31/acceder-au-raspberry-pi-via-bonjour/)
* [Avahi](https://www.poftut.com/linux-avahi-daemon-tutorial-examples/)
* [mDSN](https://www.win.tue.nl/~johanl/educ/IoT-Course/mDNS-SD%20Tutorial.pdf)

### Installation des outils
    sudo apt-get install avahi-utils
    
### Configuration

    sudo nano /etc/avahi/services/device-info.service

        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
                <type>_device-info._tcp</type>
                <port>0</port>
                <txt-record>model=RackMac</txt-record>
                <txt-record>model=TimeCapsule</txt-record>
            </service>
        </service-group>

    sudo nano /etc/avahi/services/ssh.service
    
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service>
                <type>_ssh._tcp</type>
                <port>22</port>
            </service>
        </service-group>

    sudo systemctl restart avahi-daemon
    #sudo /etc/init.d/avahi-daemon restart

### Découverte des services
    # tous
    avahi-browse -t -r -d local -a
    # ssh
    avahi-browse -t -r -d local _ssh._tcp
    # ssh "parsable"
    avahi-browse -t -r -d local _ssh._tcp -p
    # autres
    avahi-browse -t -r -d local _sleep-proxy._udp
    avahi-browse -t -r -d local _acp-sync._tcp
    avahi-browse -t -r -d local _adisk._tcp
    avahi-browse -t -r -d local _airport._tcp
    avahi-browse -t -r -d local _afpovertcp._tcp
    avahi-browse -t -r -d local _companion-link._tcp
    avahi-browse -t -r -d local _device-info._tcp
    avahi-browse -t -r -d local _sftp-ssh._tcp
    avahi-browse -t -r -d local _smb._tcp
    avahi-browse -t -r -d local _ssh._tcp
    avahi-browse -t -r -d local _http-alt._tcp
    avahi-browse -t -r -d local _ipp._tcp
    avahi-browse -t -r -d local _scanner._tcp
    avahi-browse -t -r -d local _printer._tcp
    avahi-browse -t -r -d local _uscan._tcp
    avahi-browse -t -r -d local _pdl-datastream._tcp
    avahi-browse -t -r -d local _dedicarz-rest._tcp
    avahi-browse -t -r -d local _dedicarz-rpc._tcp
    avahi-browse -t -r -d local _dedicarz-ws._tcp
    # lister les machines
    avahi-browse -t -r -d local _device-info._tcp -p|awk -F\; '{if ("" != $7) print $3, $7, $8, $10}'
    # lister les domaines
    avahi-browse-domains -t -a
    avahi-browse-domains -t -a -r
    # trouver le nom associé à une adresse
    avahi-resolve -a <adresse IPv4 ou IPv6>
    # trouver l'adresse IPv4 associée à un nom
    avahi-resolve -n -4 <nom>.local
    # trouver l'adresse IPv6 associée à un nom
    avahi-resolve -n -6 <nom>.local
    # découverte du servive mDNS
    sudo nmap -Pn -sU -p 5353 --script=dns-service-discovery <masque ssous-réseau>
    # DHCP
    sudo nmap -sU -p 67 --script=dhcp-discover <masque sous-réseau>
    
###    Découverte des services sur MacOS

* [Apple Bonjour](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/NetServices/Introduction.html)
* 

    #// découverte des services
    dns-sd -B _services._dns-sd._udp local
    
    dns-sd -B _sleep-proxy._udp local
    dns-sd -B _ssh._tcp local
    dns-sd -B _http._tcp local
    dns-sd -B _http-alt._tcp local
    dns-sd -B _ipp._tcp local
    ...

    dns-sd -G v4v6 <nom machine>.local

## Faire une liste non exhaustive des machines du réseau (Wifi) local avec nmap et avahi

### Création du scripte ~/bin/listereseau

        #!/bin/bash

        liste_cartes()
        {
           # MacOS
           ifconfig -u -l inet >/dev/null 2>&1
           if [ 1 = $? ]
           then
              # Linux
              echo "$(ifconfig -s|grep -v 'Iface'|awk '{ print $1;}')"
           else
              # MacOS
              echo "$(ifconfig -u -l inet)"
           fi
        }
        liste_caracts()
        {
           for i in $(liste_cartes)
           do
              for c in "$(ifconfig $i|grep 'inet '|awk -v i=$i '{ if ("" != $6) print "CARTE=" i ";" "IP=" $2 ";" "BR=" $6;}')"
              do
                 if [ "" != "$c" ]; then echo "$c"; fi
              done
           done
        }

        dec2hex()
        {
           local declare -a D2X
           D2X=({{0..9},{a..f}}{{0..9},{a..f}})
           echo ${D2X[$1]}${D2X[$2]}${D2X[$3]}${D2X[$4]}
        }

        dec2bin()
        {
           local declare -a D2B
           D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
           echo ${D2B[$1]}${D2B[$2]}${D2B[$3]}${D2B[$4]}
        }

        masque()
        {
           local MN=$(dec2bin $(echo $1|awk -F. '{print  $1, $2, $3, $4;}'))
           MN=${MN%1*}
           echo $((${#MN} + 1))
        }

        for l in $(liste_caracts)
        do
           unset CARTE IP BR
           eval $l
           if [ "0" = "${NM%x*}" ]
           then
              NM=$(echo $((16#${NM:2:2})).$((16#${NM:4:2})).$((16#${NM:6:2})).$((16#${NM:8:2})))
           fi
           echo -n $CARTE - $IP - $NM - $BR "-> "
           MQ=$BR/$(masque $NM)
           echo MQ=$MQ
           
           # Détection des machines du sous-réseau
           nmap -sP $MQ|grep "^Nmap scan report for "|awk '{print $5;}'
           
           # Détection des machines du sous-réseau avec Avahi si présent
           which avahi-resolve >/dev/null 2>&1
           if [ 0 = $? ]
           then
              echo Zeroconf
              for ip in $(sudo nmap --script=dns-service-discovery -p 5353 $MQ|grep "^Nmap scan report for "|awk '{print $5;}')
              do
                 avahi-resolve -a $ip 2>/dev/null
              done
           fi
        done

### Utilisation de Python

    # Installation de zeroconf
    sudo -H pip3 install zeroconf
    
    # Création du scripte ~/bin/liste_zero.py
    
        #!/usr/bin/env python3

        from six.moves import input
        from zeroconf import ServiceBrowser, Zeroconf, ZeroconfServiceTypes
        import ipaddress

        class MyListener(object):

            def remove_service(self, zeroconf, type, name):
                print("Service %s removed" % (name,))

            def add_service(self, zeroconf, type, name):
                info = zeroconf.get_service_info(type, name)
                for address in info.addresses:
                    print("{}:{}:{}:{}:{}".format(name, type, info.port, info.server, ipaddress.ip_address(address).exploded))


        if "__main__" == __name__:
            zeroconf = Zeroconf()
            listener = MyListener()
            browsers = []

            for service in ZeroconfServiceTypes.find():
                browser = ServiceBrowser(zeroconf, service, listener)
                browsers.append(browser)

            try:
                for browser in browsers:
                    browser.join(0.2)
                    browser.cancel()
                    
            finally:
                zeroconf.close()
    
    # Création du scripte ~/bin/listezeroconf
    
        #!/bin/bash

        echo
        ~/bin/liste_zero.py|awk -F: '{print substr($4,0,length($4) - 1), $5;}'|sort -u
        echo


## Activation/désactivation LED
### Lectures

* [Eteindre les LED du Raspberry Pi](https://www.journaldulapin.com/2016/02/23/eteindre-led-raspberry/)
* [...](https://www.journaldulapin.com/2015/08/26/controler-les-led-du-raspberry-pi/)
* [kernel](https://www.kernel.org/doc/Documentation/leds/leds-class.txt)


### Activer le support GPIO (désactivé par défaut)

    echo gpio | sudo tee /sys/class/leds/led1/trigger
    
### Passer la LED PWR en détection d’une sous-tension.

    echo input | sudo tee /sys/class/leds/led1/trigger
    
### Passer la LED ACT sur les accès au CPU (mettre mmc0 à la place de cpu0 pour la carte mémoire).

    echo cpu0 | sudo tee /sys/class/leds/led0/trigger

### Pour désactiver la LED ACT sur A, B, A+, B+ et 2

    dtparam=act_led_trigger=none
    dtparam=act_led_activelow=off

### Pour désactiver la LED PWR sur A+, B+ et 2

    dtparam=pwr_led_trigger=none
    dtparam=pwr_led_activelow=off

### Pour désactiver la LED sur Zero

    dtparam=act_led_trigger=none
    dtparam=act_led_activelow=on


### Basculer une LED

#### Scripte ~/bin/led_on_off

        #!/bin/sh
        # basculer une LED
        led=$(basename $0)
        switch=${led##*_}
        led=${led%%_*}
        case $led in
           act)
              LED=/sys/class/leds/led1
              ;;
           pwr)
              LED=/sys/class/leds/led0
              ;;
           *)
              LED=/sys/class/leds/led0
              ;;
        esac

        echo "LED $LED -> $switch"
        
        if [ "on" = "$switch" ]
        then
          MAX=$(cat ${LED}/max_brightness)
          echo $MAX | sudo tee ${LED}/brightness > /dev/null
        else
          echo 0 | sudo tee ${LED}/brightness > /dev/null
        fi

#### Création des liens symboliques

        ln -s ~/bin/led_on_off ~/bin/pwr_led_on
        ln -s ~/bin/led_on_off ~/bin/pwr_led_off
        ln -s ~/bin/led_on_off ~/bin/act_led_on
        ln -s ~/bin/led_on_off ~/bin/act_led_off

### Obtenir le statut (on, off) d'une LED

#### Scripte ~/bin/led_status

        #!/bin/bash

        led=$(basename $0)
        led=${led%%_*}

        case $led in
           capslock|compose|kana|numlock|scrolllock)
              LED=/sys/class/leds/input0\:\:$led
              ;;
           act)
              LED=/sys/class/leds/led1
              ;;
           pwr)
              LED=/sys/class/leds/led0
              ;;
           *)
              LED=/sys/class/leds/led0
              ;;
        esac

        echo -n "LED $LED "

        if [ 0 = $(cat $LED/brightness) ]; then echo off; else echo on; fi

#### Création des liens symboliques

        ln -s ~/bin/led_status ~/bin/act_led_status
        ln -s ~/bin/led_status ~/bin/pwr_led_status
        ln -s ~/bin/led_status ~/bin/capslock_led_status
        ln -s ~/bin/led_status ~/bin/compose_led_status
        ln -s ~/bin/led_status ~/bin/kana_led_status
        ln -s ~/bin/led_status ~/bin/numlock_led_status
        ln -s ~/bin/led_status ~/bin/scrolllock_led_status


## Gestion des alias

### Scripte  ~/.bash_aliases 

    echo "définition des alias"

    alias view='nano -c -w -v'
    alias nano='nano -c -w'

    alias ll='ls -l'
    alias la='ls -lA'

## Gestion du PATH (inspiré de MacOS et de la gestion des alias)

### Ajout dans ~/.profile

    ## PLB
    #
    # Path definitions.
    if [ -f ~/.bash_paths ]; then
    . ~/.bash_paths
    fi

### Création de ~/.bash_paths

    #!/bin/bash

    # Définition du PATH
    # si le répertoire existe
    if [ -d ~/.paths.d ]
    then
      echo "définition du PATH"
      l="$PATH"
      # pour chaque fichier présent dans le répertoire
      for f in $(ls -1 ~/.paths.d/)
      do
        # lire les chemins contenus dans le fichier
        for p in $(cat ~/.paths.d/$f)
        do
          # vérifier si le chemin existe
          if [ -d "$p" ]
          then
            # vérifier que le chemin n'est pas déjà dans le PATH
            echo ":$l:"|grep ":$p:" > /dev/null
            if [ 1 = $? ]
            then
              # ajouter le chemin au début du PATH
              l="$p:$l"
            fi
          fi
        done
        unset p
      done
      unset f
      export PATH="$l"
      unset l
    fi

### Création de ~/paths.d

    mkdir ~/paths.d/

### Création de ~/paths.d/pi

    /home/pi/bin
    /home/pi/.local/bin

## Gestion des mises-à-jour python

### Création du scripte ~/bin/pipupgrade

    #!/bin/bash

    sudo pip3 install -U pip setuptools

    pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U --ignore-installed
    #pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U

## Installation de Jupyter avec Buster

### Création du scripte ~/bin/pipinstall

    #!/bin/bash

    # Intallation de 'jupterlab'
    #
    for p in jupyterlab jupyterlab_latex jupyter_nbextensions_configurator
    do
    sudo -H pip3 install -U $p
    done
    python3 -m jupyter serverextension enable --user jupyterlab_latex
    python3 -m jupyter serverextension list --user

    # Installation de paquets complementaires
    #
    for p in numpy matplotlib pandas skyfield Cython
    do
    sudo -H pip3 install -U $p
    done

    # Installation du paquet scipy
    #
    sudo -H apt-get -y install libatlas-base-dev python3-dev libopenblas-dev gfortran
    # attendre un certain temps...
    sudo -H pip3 install -U scipy

    # Installation dépendances PyGobject

    sudo apt install libglib2.0-dev libgirepository1.0-dev libcairo2-dev
    
## Commande root

### Création du scripte ~/bin/root

    #!/bin/bash
    user=$(basename $0)
    echo "$user"
    if [ $# -eq 0 ]
    then
      sudo -u $user -i
    else
      if [ "docker" = "$user" ]
      then
        sudo -u $user docker $*
      else
        sudo -u $user $*
      fi
    fi
    
## Installer Samba (Time Machine)

### Lectures
* [installation](https://www.journaldulapin.com/2018/05/05/time-machine-smb-2/)
* [...](https://medium.com/@abjurato/using-raspberry-pi-as-an-apple-timemachine-d2fceecb6876)
* [Samba](http://www.macdweller.org/2012/05/13/samba-bonjour-with-avahi/)
* [...](https://www.aide-sys.fr/tuto-samba-installation-configuration/)
* [Time Machine](https://linit.io/mettre-en-place-un-serveur-time-machine-sur-linux/)
* 

### Installation du paquet Samba

    sudo apt install samba netatalk
    
### Création du dossier (point de montage)

    DOSSIER="/smb/time_machine"
    
    sudo mkdir -p ${DOSSIER}
    sudo chmod -R -f 777 ${DOSSIER}
    
### Création de la partition

    DISQUE="/dev/sda"
    
    sudo fdisk ${DISK}
        n
        ...

    PART="${DISQUE}2"
    sudo mkfs.ext4 ${PART} -L "Time Machine Rpi4"
    blkid ${PART}
    blkid ${PART}|awk -F': ' '{print $2;}'

### Changer l'UUID d'une partition (si nécessaire)

    umount ${PART}
    blkid ${PART}
    tune2fs -U random ${PART}
    # tune2fs -U '<UUID>' ${PART}
    blkid ${PART}
    mount ${PART}

### Changer le LABEL d'une partition (si nécessaire)

    umount ${PART}
    blkid ${PART}
    tune2fs -L '<LABEL>' ${PART}
    blkid ${PART}
    mount ${PART}


### Configuration /etc/fstab

    eval $(blkid ${PART}|awk -F': ' '{print $2;}')
    echo TYPE=${TYPE}
    echo PARTUUID=${PARTUUID}

    echo "PARTUUID=${PARTUUID} ${DOSSIER} ${TYPE} defaults 0 2"|sudo tee -a /etc/fstab
    cat /etc/fstab
    sudo mount ${PART}
    ls -la ${DOSSIER}
    
### Configuration Samba

    #// sauvegarder la configuration d'origine
    
    sudo cp -v /etc/samba/smb.conf /etc/samba/smb.conf.origin
    CARTE=wlan0   
    IP="$(ifconfig ${CARTE}|grep "inet "|awk '{print $6;}'|sed -e 's|255|0|g')"/24
    # ligne à ajouter au niveau interfaces
    echo "    interfaces = $IP $CARTE"

    
    #// modifications du fichier /etc/samba/smb.conf
    
    [global]
        workgroup = <...>
        interfaces = <IP> <CARTE>
        bind interfaces only = yes
        hide files = /lost+found/
    # ...
    #------------------------------
    # Time Machine
       log level = 2
       mdns name = mdns
       fruit:veto_appledouble = no
       fruit:encoding = native
       fruit:metadata = stream
    # Security
       server min protocol = SMB2
    #------------------------------
    # ...
    
    #------------------------------
    [Time Machine Rpi4]
        vfs objects = catia fruit streams_xattr
        fruit:time machine = yes
        fruit:resource = file
        fruit:metadata = netatalk
        fruit:locking = netatalk
        fruit:encoding = native
        path = /smb/time_machine
        guest only = yes
        writeable = yes
    #------------------------------

    #// Tester la configuration
    
    sudo smbd -s /etc/samba/smb.conf

    #// Redémarrer Samba
    
    sudo systemctl restart smbd.service
    #sudo reboot

    #// modifications du fichier /etc/netatalk/afp.conf
    
    [Global]
      mimic model = TimeCapsule6,106

    [Time Machine Rpi4]
      path = /smb/time_machine
      time machine = yes


### Configuration Avahi

    sudo nano /etc/avahi/services/smb.service
    
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
        
    sudo nano /etc/avahi/services/afpd.service
    
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_afpovertcp._tcp</type>
            <port>548</port>
          </service>
          <!--<service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=TimeCapsule</txt-record>
          </service>-->
        </service-group>

    sudo nano /etc/avahi/services/airport.service
    
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_airport._tcp</type>
            <port>5009</port>
          </service>
        </service-group>



## Jenkins

### Lectures

* [Installation](https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Ubuntu)
* [...](https://www.techcoil.com/blog/how-i-setup-jenkins-on-my-raspberry-pi-3-with-raspbian-stretch-lite/)
* [...](http://pkg.jenkins-ci.org/debian/)
* [Initiation](https://alexandre-laurent.developpez.com/tutoriels/initiation-ci-jenkins/)
* [...](http://jenkins.io/doc/pipeline/tour/running-multiple-steps/)
* [...](https://pypi.org/project/unittest-xml-reporting/)
* 
### Installation
        wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
        echo 'deb http://pkg.jenkins-ci.org/debian binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list
        sudo apt-get update
        sudo apt-get install jenkins -y
        # vérification
        systemctl status jenkins.service
        # redémarrage
        sudo systemctl restart jenkins.service
                
### API JSON
        
        wget -q --auth-no-challenge --user <user> --password <password> --output-document - 'http://<host>:<port>/api/json?pretty=true'

### Token JSON

    wget -q --auth-no-challenge --user <user> --password <password> --output-document - 'http://<host>:<port>/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'
    
    ->  Jenkins-Crumb:2a17714...ddde18d

### Utilistaion avec Python
    
        #// installation xmlrunner
        sudo -H pip3 install xmlrunner unittest-xml-reporting
        
        #// fichier Jenkinsfile
        
        pipeline {
            agent any
            stages {
                stage('Test') {
                    steps {
                        sh 'python3 -m xmlrunner -o reports discover'
                    }
                }
            }
            post {
                always {
                    echo 'This will always run'
                    junit 'reports/**/TEST-*.xml'
                }
                success {
                    echo 'This will run only if successful'
                }
                failure {
                    echo 'This will run only if failed'
                }
                unstable {
                    echo 'This will run only if the run was marked as unstable'
                }
                changed {
                    echo 'This will run only if the state of the Pipeline has changed'
                    echo 'For example, if the Pipeline was previously failing but is now successful'
                }
            }
        }

## Raspberry Pi

### Lectures

* [problèmes USB 3](https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=245931)
* [bootloader](https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md)
* [...](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md)
* 
    
### Obtenir les informations nécessaires

    #// si nécessaire débrancher délicatement le disque USB cible
    #// effacer le journal
    sudo dmesg -C
    #// brancher le disque USB cible
    dmesg
    #// noter le 'idVendor' et le 'idProduct'
    lsblk -o name,label,partuuid
    #// noter le 'PARTUUID'
    nano <...cmdline.txt>
    #// ajouter 'usb-storage.quirks=<idVendor>:<idProduct>:u ' dans /boot/cmdline.txt au début de la ligne
    #// pour voir après le démarrage
    findmnt
    

## Divers

    #Created symlink /etc/systemd/system/default.target → /lib/systemd/system/multi-user.target
    #Created symlink /etc/systemd/system/default.target → /lib/systemd/system/graphical.target.
    
    ### Lectures
    
* [vcgencmd](https://elinux.org/RPI_vcgencmd_usage)
* [...](https://github.com/nezticle/RaspberryPi-BuildRoot/wiki/VideoCore-Tools)
* 

    vcgencmd commands
    commands="vcos, ap_output_control, ap_output_post_processing, vchi_test_init, vchi_test_exit, vctest_memmap, vctest_start, vctest_stop, vctest_set, vctest_get, pm_set_policy, pm_get_status, pm_show_stats, pm_start_logging, pm_stop_logging, version, commands, set_vll_dir, set_backlight, set_logging, get_lcd_info, arbiter, cache_flush, otp_dump, test_result, codec_enabled, get_camera, get_mem, measure_clock, measure_volts, enable_clock, scaling_kernel, scaling_sharpness, get_hvs_asserts, get_throttled, measure_temp, get_config, hdmi_ntsc_freqs, hdmi_adjust_clock, hdmi_status_show, hvs_update_fields, pwm_speedup, force_audio, hdmi_stream_channels, hdmi_channel_map, display_power, read_ring_osc, memtest, dispmanx_list, get_rsts, schmoo, render_bar, disk_notify, inuse_notify, sus_suspend, sus_status, sus_is_enabled, sus_stop_test_thread, egl_platform_switch, mem_validate, mem_oom, mem_reloc_stats, hdmi_cvt, hdmi_timings, readmr, bootloader_version, bootloader_config, file"
    ### température 
    vcgencmd measure_temp

## SSL avec Nginx

### Lectures

* [nginx](https://www.techcoil.com/blog/building-a-reverse-proxy-server-with-nginx-certbot-raspbian-stretch-lite-and-raspberry-pi-3/)
* [CA](https://mespotesgeek.fr/fr/creation-dun-root-ca-sous-openssl/)
* 

    #// installation nginx
    
    sudo apt-get update
    sudo apt-get install nginx -y 
    systemctl status nginx.service
    
    #// installation certbot
    
    sudo apt-get install certbot python-certbot-nginx -y
    
    #// configurer nginx
    
    sudo nano /etc/nginx/sites-enabled/lhb97.eu.conf
    
        server {
            listen 80;
            server_name  lhb97.eu;
         
            root /var/www/lhb97.eu;
         
            location ~ /.well-known {
                allow all;
            }
        }
        
    sudo mkdir /var/www/lhb97.eu
    sudo chown www-data:www-data /var/www/lhb97.eu
    
    sudo systemctl restart nginx.service
    systemctl status nginx.service
    
    #// obtenir les éléments nécessaires avec Certbot
    sudo certbot certonly -a webroot --webroot-path=/var/www/lhb97.eu -d lhb97.eu
    
    sudo certbot --nginx


### PyCharm

    cd ~/Downloads
    PYVERS=2019.2.3
    wget https://download.jetbrains.com/python/pycharm-community-${PYVERS}.tar.gz
    wget https://download.jetbrains.com/python/pycharm-community-${PYVERS}.tar.gz.sha256
    sha256sum pycharm-community-${PYVERS}.tar.gz -c pycharm-community-${PYVERS}.tar.gz.sha256
    tar -xzf pycharm-community-${PYVERS}.tar.gz -C ~/
    unlink ~/pycharm-community
    ln -s ~/pycharm-community-${PYVERS} ~/pycharm-community
    mkdir ~/pycharm-community/config
    echo $HOME/pycharm-community/bin > ~/.paths.d/pycharm
    . ~/.bash_paths
    echo $PATH

    #// besoin d'un mode graphique
    pycharm.sh



## USB Camera

### Lectures

* [Installation](https://www.raspberrypi.org/documentation/usage/webcams/)
* 
        sudo apt-get install guvcview fswebcam cheese
        # sudo usermod -a -G video <username>
        #// test
        #fswebcam image.jpg
