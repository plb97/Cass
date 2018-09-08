#  Cass

## Multistrap

### Lectures

* [Multistrap](https://bootlin.com/blog/embdebian-with-multistrap/)
* 


    #// installer 'multistarp'
    sudo apt-get -y install multistrap dpkg-dev
    #// creer un repertoire de travail
    ARCH=arm64
    DIR=$(pwd)/rpi64
    #// creer le fichier de configuration
    cat > rpi64.conf <<EOF
    [General]
    arch=${ARCH}
    directory=${DIR}
    # same as --tidy-up option if set to true
    cleanup=true
    # same as --no-auth option if set to true
    # keyring packages listed in each bootstrap will
    # still be installed.
    noauth=true
    # extract all downloaded archives (default is true)
    unpack=true
    # enable MultiArch for the specified architectures
    # default is empty
    multiarch=
    # aptsources is a list of sections to be used for downloading packages
    # and lists and placed in the /etc/apt/sources.list.d/multistrap.sources.list
    # of the target. Order is not important
    aptsources=Debian
    # the order of sections is not important.
    # the bootstrap option determines which repository
    # is used to calculate the list of Priority: required packages.
    bootstrap=Debian
    
    [Debian]
    packages=wpasupplicant wireless-tools passwd dhcpcd5 wget nano bash net-tools ifupdown2
    source=http://ftp.fr.debian.org/debian/
    keyring=debian-archive-keyring
    #components=main non-free
    suite=stretch
    EOF

    sudo multistrap -a ${ARCH} -d ${DIR} -f rpi64.conf > rpi64.log
    
    #// voir NOTE.md : Contruire un noyau arm 64 bits
    sudo mkdir -pv ${DIR}/usr/lib/raspi-config
    sudo cp -v ${ROOTDIR}/etc/fstab ${DIR}/etc
    sudo cp -v ${ROOTDIR}/usr/lib/raspi-config/init_resize.sh ${DIR}/usr/lib/raspi-config
    sudo rm -rvf ${ROOTDIR}/*
    sudo rsync -vax ${DIR}/* ${ROOTDIR}
    sudo chown root:root -Rv ${ROOTDIR}
    exit
    
