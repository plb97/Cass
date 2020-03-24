#  Cass

## Setting up a Raspberry Pi as an access-point in a standalone network (NAT)

### Lectures

* [Access-point](https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md)
* [Partage de connexion Internet](https://doc.ubuntu-fr.org/partage_de_connexion_internet)
* [hostapd](https://doc.ubuntu-fr.org/hostapd)
* [...](http://hardware-libre.fr/2014/02/raspberry-pi-creer-un-point-dacces-wifi/)
* [...](https://zsiti.eu/wifi-rtl8188eu-raspberry-pi-zero/)
* [...](http://www.crack-wifi.com/forum/topic-12270-nommage-interface-wifi.html)
* [...](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/)
* [OpenVPN](https://www.lnaze.net/hostspot-openvpn-raspberry/)
* [...](https://techwiser.com/clear-dns-cache-on-browser/)
* [PureVPN](https://support.purevpn.com/linux-openvpn-command)
* [iptables](https://debian-facile.org/doc:reseau:iptables-pare-feu-pour-un-client)
* [...](http://olivieraj.free.fr/fr/linux/information/firewall/fw-03-07.html)
* [...](http://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-sg-fr-4/s1-firewall-ipt-fwd.html)
* [...](https://www.systutorials.com/816/port-forwarding-using-iptables/)
* [...](http://irp.nain-t.net/doku.php/130netfilter:start)
* [...](https://upandclear.org/2016/06/25/iptables-faut-pas-en-avoir-peur-regles-openvpn-secu/)
* [WOL](https://www.freedesktop.org/software/systemd/man/systemd.link.html)
* [Raspberry wifi configuration](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md)
* [Raspberry wifi passerelle](https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md)
* 

## Lister les cartes réseau "physiques" (docker0 comprise le cas échéant)

    ip -4 -o addr show scope global|grep -v '\(br-\|veth\)'
    ip link|awk '1==NR%2 {printf "NIC=%-15s ",substr($2,0,length($2));} 0==NR%2 {nam=$2;gsub(":","",nam);printf "MAC=%s NAM=%s\n",$2,nam;}'|grep -v '^NIC=\(lo \|veth\|br-\)'

## Obtenir le nom des cartes réseau et leur IP associée (autres que wlan0 et docker0)

### Activer l'option de nommage prévisible des interfaces réseau

    unlink /etc/systemd/network/99-default.link
    #// redemarrage
    reboot

### Ethernet (option 'nommage prévisible des interfaces réseau' activée)

    eval $(ip -o -4 addr show|grep enx|awk '1==NR { print "EN0=" $2, "EN0_IP=" substr($4,1,index($4,"/")-1), "EN0_MAS="$6; }')
    echo "EN0=${EN0} EN0_IP=${EN0_IP} EN0_MAS=${EN0_MAS}"

### LAN (option 'nommage prévisible des interfaces réseau' activée)

    eval $(ip -o -4 addr show|grep wlx|awk '1==NR { print "LAN=" $2, "LAN_IP=" substr($4,1,index($4,"/")-1), "LAN_MAS="$6; }')
    echo LAN=${LAN} LAN_IP=${LAN_IP} LAN_MAS=${LAN_MAS}
    
## Définir le nom d'une carte réseau

### Carte Wifi interne : wlan0  (option 'nommage prévisible des interfaces réseau' activée)

Le nom de la carte wifi interne n'est pas systématiquement wlan0, il arrive qu'elle soit nommée wlan1, pour écarter cette incertitude, il faut forcer le nommage.

    eval $(ip link|awk '1==NR%2 {printf "NIC=%-15s ",substr($2,0,length($2));} 0==NR%2 {nam=$2;gsub(":","",nam);printf "MAC=%s NAM=%s\n",$2,nam;}'|grep -v '^NIC=\(lo \|veth\|br-\)'|grep wlan)
    echo NIC=${NIC} MAC=${MAC} NAM=${NAM}
    echo "# /etc/systemd/network/10-${NAM}.link
        [Match]
            MACAddress=${MAC}
        [Link]
            Name=wlan0
        " | sed -e "s|^        ||g" > /etc/systemd/network/10-${NAM}.link
    cat /etc/systemd/network/10-${NAM}.link

### Carte Ethernet interne : en0 (option 'nommage prévisible des interfaces réseau' activée)

    eval $(ip link|awk '1==NR%2 {printf "NIC=%-15s ",substr($2,0,length($2));} 0==NR%2 {nam=$2;gsub(":","",nam);printf "MAC=%s NAM=%s\n",$2,nam;}'|grep -v '^NIC=\(lo \|veth\|br-\)'|grep enx)
    echo NIC=${NIC} MAC=${MAC} NAM=${NAM}
    echo "# /etc/systemd/network/11-${NAM}.link
        [Match]
            MACAddress=${MAC}
        [Link]
            Name=en0
            WakeOnLan=phy
        " | sed -e "s|^        ||g" > /etc/systemd/network/11-${NAM}.link
    cat /etc/systemd/network/11-${NAM}.link

### Carte Wifi externe : wl1 (option 'nommage prévisible des interfaces réseau' activée)

    eval $(ip link|awk '1==NR%2 {printf "NIC=%-15s ",substr($2,0,length($2));} 0==NR%2 {nam=$2;gsub(":","",nam);printf "MAC=%s NAM=%s\n",$2,nam;}'|grep -v '^NIC=\(lo \|veth\|br-\)'|grep wlx)
    echo NIC=${NIC} MAC=${MAC} NAM=${NAM}
    echo "# /etc/systemd/network/12-${NAM}.link
        [Match]
            MACAddress=${MAC}
        [Link]
            Name=wl1
        " | sed -e "s|^        ||g" > /etc/systemd/network/12-${NAM}.link
    cat /etc/systemd/network/12-${NAM}.link


### Désactiver l'option de nommage prévisible des interfaces réseau

    ln -s /dev/null /etc/systemd/network/99-default.link
    #// redemarrage
    reboot

## Installer et configurer Hostapd (option 'nommage prévisible des interfaces réseau' désactivée)

### Installer le pilote de la carte TP-Link TL-WN725N (à refaire en cas de mise-à-jour du noyau)

En tant que 'root'

    mkdir hostapd && cd hostapd
    rel=$(uname -r|sed -e 's|+$||')
    echo rel=${rel}
    ver=$(uname -v|sed -e 's|^#\([[:digit:]]\+\).*|\1|')
    echo ver=${ver}
    tgz=8188eu-${rel}-${ver}.tar.gz
    echo tgz=${tgz}
    wget http://downloads.fars-robotics.net/wifi-drivers/8188eu-drivers/${tgz}
    if [ -f ${tgz} ]
    then
        tar zvxf ${tgz}    
        ./install.sh
    fi
    cd ..
    rm -rv hostapd
    
    reboot

### Configurer 'hostapd' (en tant que 'root')

    #// installer les outils necessaires et utiles
    apt-get -y install hostapd dnsmasq iptables tcpdump nmap conntrack

    LAN=wl1
    echo LAN=${LAN}
    LAN_IP=$(ip -4 -o address show ${LAN}|awk '1==NR {print $4;}'|awk -F/ '{print $1;}')
    echo LAN_IP=${LAN_IP}
    LAN_NET=$(ip -4 -o route list dev ${LAN}|grep -v '^default '|grep ${LAN_IP}|cut -d ' ' -f 1)
    echo LAN_NET=${LAN_NET}
    
    EN0=$(ip -o -4 addr show en0|awk '1==NR { print $2; }')
    WAN=${EN0:-wlan0}
    echo WAN=${WAN}
    WAN_IP=$(ip -4 -o address show ${WAN}|awk '1==NR {print $4}'|awk -F/ '{print $1;}')
    echo WAN_IP=${WAN_IP}
    WAN_NET=$(ip -4 -o route list dev ${WAN}|grep -v '^default '|grep ${WAN_IP}|cut -d ' ' -f 1)
    echo WAN_NET=${WAN_NET}

    NUM=$(echo $(hostname)|sed -e 's|^[[:alpha:]]*||g')    #// dans le cas ou le nom de machine est du type 'xyz123'
    echo NUM=${NUM}
    NET="192.168.$((NUM * 10 % 256))"
    echo NET=${NET}

    #SSID="$(hostname)_$(ip -o -4 link show ${LAN}|awk -F 'link/ether ' '{ print $2; }'|cut -d ' ' -f 1|sed -e 's|:||g')"
    SSID="$(hostname)"
    #SSID=${SSID%%.*}
    #SSID=${SSID^^*}
    echo SSID=${SSID}
    #CHANNEL=6
    #CHANNEL=$((RANDOM % 14 + 1))
    CHANNEL=$(((NUM + 13) % 14 + 1))
    echo CHANNEL=${CHANNEL}
    PASSPHRASE=MotDePasse
    echo PASSPHRASE=${PASSPHRASE}
    
    echo "# /etc/hostapd/hostapd.conf
        ctrl_interface_group=0
        ctrl_interface=/var/run/hostapd
        # interface wlan du Wi-Fi
        interface=${LAN}
        # nl80211 avec tous les drivers Linux mac80211 
        #driver=nl80211
        # Nom du spot Wi-Fi
        ssid=${SSID}
        # mode Wi-Fi (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g)
        hw_mode=g
        # ssid visible (=0) invisible (=1)
        ignore_broadcast_ssid=0
        # Beacon interval in kus (1.024 ms)
        beacon_int=100
        # DTIM (delivery trafic information message) 
        dtim_period=2
        # Maximum number of stations allowed in station table
        max_num_sta=255
        # RTS/CTS threshold; 2347 = disabled (default)
        rts_threshold=2347
        # Fragmentation threshold; 2346 = disabled (default)
        fragm_threshold=2346
        # canal de fréquence Wi-Fi (1-14)
        channel=${CHANNEL}
        # Wi-Fi ouvert, pas d'authentification !
        #auth_algs=0
        ## Authentification WPA/WPA2
        #auth_algs=1
        #wpa=1
        ##wpa_psk=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
        #wpa_passphrase=${PASSPHRASE}
        #wpa_key_mgmt=WPA-PSK
        #wpa_pairwise=TKIP
        # Authentification WPA2 (WPA2-PSK-CCMP)
        auth_algs=2
        wpa=2
        #wpa_psk=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
        wpa_passphrase=${PASSPHRASE}
        wpa_key_mgmt=WPA-PSK
        wpa_pairwise=CCMP
        " | sed -e "s|^        ||g" > /etc/hostapd/hostapd.conf
        cat /etc/hostapd/hostapd.conf

### Tester 'hostapd' et finir de le configurer

    #// lancer 'hostapd'
    rm -v hostapd.log hostapd.pid
    hostapd -d -B -f hostapd.log -P hostapd.pid /etc/hostapd/hostapd.conf
    tail -f hostapd.log
    #// arreter 'hostapd'
    kill $(cat hostapd.pid)
    
    grep 'DAEMON_CONF=' /etc/default/hostapd
    sed -i -e 's|^#\s*DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd
    grep 'DAEMON_CONF=' /etc/default/hostapd


### Configurer 'dnsmasq'

    mv -v /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    echo "# /etc/dnsmasq.conf
        interface=${LAN}
        dhcp-range=${NET}.100,${NET}.200,255.255.255.0,12h
        " | sed -e "s|^        ||g" > /etc/dnsmasq.conf
    cat /etc/dnsmasq.conf

### Configurer l'interface réseau et les tables de routage

    grep 'net.ipv4.ip_forward' /etc/sysctl.conf
    sed -i -e 's|^#\s*net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf
    grep 'net.ipv4.ip_forward' /etc/sysctl.conf
    sysctl net.ipv4.ip_forward
    #sysctl -w net.ipv4.ip_forward=1
    sysctl -p /etc/sysctl.conf
    sysctl net.ipv4.ip_forward
    
    mkdir -v /etc/iptables
    iptables-save > /etc/iptables/origin.ipv4.nat # peut etre vide si aucune regle n'a ete definie
    iptables -t nat -A POSTROUTING ! -d ${LAN_NET} -o ${WAN} -j MASQUERADE
    iptables -A FORWARD -i ${WAN} -o ${LAN} -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ${LAN} -o ${WAN} -j ACCEPT
    iptables-save > /etc/iptables/${LAN}.ipv4.nat
    cat /etc/iptables/${LAN}.ipv4.nat
    
    echo "# /etc/network/interfaces.d/${LAN}
        allow-hotplug ${LAN}
        iface ${LAN} inet static
            address ${NET}.1
            network ${NET}.0
            broadcast ${NET}.255
            netmask 255.255.255.0
            up iptables-restore < /etc/iptables/${LAN}.ipv4.nat
        " | sed -e "s|^        ||g" > /etc/network/interfaces.d/${LAN}
    cat /etc/network/interfaces.d/${LAN}

    reboot

## PureVPN

### Configurer 'iptables' pour OpenVPN

    #// en tant que 'root'
    
    LAN=wl1
    LAN_IP=$(ip -4 -o address show ${LAN}|awk '1==NR {print $4;}'|awk -F/ '{print $1;}')
    echo LAN_IP=${LAN_IP}
    LAN_NET=$(ip -4 -o route list dev ${LAN}|grep -v '^default '|grep ${LAN_IP}|cut -d ' ' -f 1)
    echo LAN_NET=${LAN_NET}

    #EN0=$(ip -o -4 addr show en0|awk '1==NR { print $2; }')
    #WAN=${EN0:-wlan0}
    #echo WAN=${WAN}
    #WAN_IP=$(ip -4 -o address show ${WAN}|awk '1==NR {print $4}'|awk -F/ '{print $1;}')
    #echo WAN_IP=${WAN_IP}
    #WAN_NET=$(ip -4 -o route list dev ${WAN}|grep -v '^default '|grep ${WAN_IP}|cut -d ' ' -f 1)
    #echo WAN_NET=${WAN_NET}
    
    TUN=tun0
    #TUN_IPM=$(ip -4 -o address show ${TUN}|grep -v '^default '|awk '1==NR {print $4}')
    #cho TUN_IPM=${TUN_IPM}
    #TUN_IP=$(echo ${TUN_IPM}|awk -F/ '{print $1;}')
    #echo TUN_IP=${TUN_IP}
    #TUN_NET=$(ip -4 -o -d route list dev ${TUN}|grep ${TUN_IP}|cut -d ' ' -f 1)
    #echo TUN_NET=${TUN_NET}

    [ ! -f /etc/iptables/${LAN}.ipv4.nat ] && iptables-save > /etc/iptables/${LAN}.ipv4.nat
    cat /etc/iptables/${LAN}.ipv4.nat
    
    iptables -t nat -I POSTROUTING 1 -s ${LAN_NET} -o tun+ -j MASQUERADE
    iptables -I FORWARD 1 -i tun+ -o ${LAN} -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -I FORWARD 1 -i ${LAN} -o tun+ -j ACCEPT
    iptables-save > /etc/iptables/${TUN}.ipv4.nat
    cat /etc/iptables/${TUN}.ipv4.nat
        
    magic="#!" # bizarre mais necessaire
    
    echo "${magic}/bin/sh
        echo $0 $*
        iptables-restore < /etc/iptables/${TUN}.ipv4.nat
        exit 0" | sed -e "s|^        ||g" > /etc/iptables/${TUN}.up.sh
    chmod +x /etc/iptables/${TUN}.up.sh
    cat /etc/iptables/${TUN}.up.sh

    if [ ! -x /etc/iptables/${LAN}.up.sh ]
    then
        echo "${magic}/bin/sh
            echo $0 $*
            iptables-restore < /etc/iptables/${LAN}.ipv4.nat
            exit 0" | sed -e "s|^            ||g" > /etc/iptables/${LAN}.up.sh
        chmod +x /etc/iptables/${LAN}.up.sh
        cat /etc/iptables/${LAN}.up.sh
    fi
    
    ln -s /etc/iptables/${LAN}.up.sh /etc/iptables/${TUN}.down.sh
    
    unset magic LAN TUN
    
### Installer PureVPN en tant que 'root'

    #// installer OpenVPN
    apt-get -y install openvpn
    #// desactiver OpenVPN
    systemctl stop openvpn
    systemctl disable openvpn
    
    OVPN_DDIR=/etc/openvpn

    #// creer le fichier d'authentification PureVPN
    user=<Utilisateur>
    pass=<MotDePasse>
    login=login.txt
    echo $user > ${OVPN_DDIR}/$login ; echo $pass >> ${OVPN_DDIR}/$login
    chmod -r ${OVPN_DDIR}/${login} && chmod u+r ${OVPN_DDIR}/${login}
    cat ${OVPN_DDIR}/${login}
    unset user pass
    
    #// preparer l'environnement OpenVPN
    lsmod | grep tun
    modprobe tun
    lsmod | grep tun
    echo tun >> /etc/modules
    mkdir -pv /var/log/openvpn /var/run/openvpn
    
    wget https://s3-us-west-1.amazonaws.com/heartbleed/linux/linux-files.zip
    unzip linux-files.zip
    rm -v linux-files.zip
    
    OVPN_SDIR=$(pwd)/OpenVPN
    mv -v "$(ls -d Linux?OpenVPN*files)" ${OVPN_SDIR}
    ls -l ${OVPN_SDIR}
    
    #// copier les fichiers d'authentification PureVPN
    cp -v ${OVPN_SDIR}/ca.crt ${OVPN_SDIR}/Wdc.key ${OVPN_DDIR}
    chmod -r ${OVPN_DDIR}/Wdc.key ${OVPN_DDIR}/ca.crt && chmod u+r  ${OVPN_DDIR}/Wdc.key ${OVPN_DDIR}/ca.crt
    ls -l ${OVPN_DDIR}

    #// creer la configuration PureVPN
    login=login.txt
    TUN=tun0
    LAN=wl1
    proto=tcp
    PROTO=$(echo ${proto}|awk '{ print toupper($1); }')
    #// la configuration par default 'purevpn.conf' sera la derniere de la liste
    liste="Quebec:Switzerland:Washington, Seattle"
    OIFS=$IFS
    IFS=':'
    echo "---"
    for ovpn in ${liste}
    do
        conf=${OVPN_DDIR}/${ovpn}.ovpn
        echo "#ovpn ${conf}" > ${conf}
        cat ${OVPN_SDIR}/${PROTO}/${ovpn}-${proto}.ovpn >> ${conf}
        sed -i -e "s|^auth-user-pass\s*|auth-user-pass ${login}|" ${conf}
        sed -i -e "s|^auth-retry interact|auth-retry nointeract|" ${conf}
        sed -i -e "s|^auth-nocache|#auth-nocache|" ${conf}
        sed -i -e "s|^route-delay|#route-delay|" ${conf}
        sed -i -e "s|^verb [[:digit:]]\+|verb 6|" ${conf}
        echo "script-security 2" >> ${conf}
        echo "up /etc/openvpn/update-resolv-conf" >> ${conf}
        echo "down /etc/openvpn/update-resolv-conf" >> ${conf}
        echo "route-up /etc/iptables/${TUN}.up.sh" >> ${conf}
        echo "route-pre-down /etc/iptables/${TUN}.down.sh" >> ${conf}
        echo 'log /var/log/openvpn/openvpn.log' >> ${conf}
        echo 'writepid /var/run/openvpn/openvpn.pid' >> ${conf}
        cat ${conf}
        ln -sf ${conf} ${OVPN_DDIR}/purevpn.conf
        echo "---"
    done
    IFS=$OIFS
    
    unset DIR login conf proto PROTO liste OIFS TUN LAN
    
### Changer de configuration OpenVPN

    ovpn=Switzerland.ovpn
    conf=/etc/openvpn/${ovpn}
    ln -sf ${conf} /etc/openvpn/purevpn.conf
    cat ${conf}
    unset conf ovpn

### Tester OpenVPN (facultatif)

    cd /etc/openvpn
    openvpn --dev tun --config purevpn.conf &
    cat /var/run/openvpn/openvpn.pid
    cat /var/log/openvpn/openvpn.log
    journalctl -ae --no-pager
    
    ##// la premiere fois peut apparaitre le message 'Please enter password with the systemd-tty-ask-password-agent tool!'
    #cat /etc/openvpn/login.txt
    #sudo systemd-tty-ask-password-agent #// entrer le 'username'
    #sudo systemd-tty-ask-password-agent #// entrer le 'password'
    
### Demarrer OpenVPN (en tant que 'root')

    curl http://ipecho.net/plain && echo
    systemctl start openvpn
    journalctl -ae --no-pager
    cat /var/log/openvpn/openvpn.log
    resolvconf -l
    curl http://ipecho.net/plain && echo
    #nmap $(curl http://ipecho.net/plain)
    
    ip -4 -o addr
    ip -4 -o route
    iptables -n -v -L
    cat /proc/net/nf_conntrack
    
    
### Arrêter OpenVPN (en tant que 'root')

    curl http://ipecho.net/plain && echo
    systemctl stop openvpn
    journalctl -ae --no-pager
    cat /var/log/openvpn/openvpn.log
    curl http://ipecho.net/plain && echo

### Activer le service OpenVPN (en tant que 'root')

    systemctl enable openvpn
    systemctl status openvpn
    reboot

### Désactiver le service OpenVPN (en tant que 'root')

    systemctl stop openvpn
    systemctl disable openvpn
    systemctl status openvpn

### Tester PureVPN

    sudo systemctl stop openvpn
    curl http://ipecho.net/plain; echo;
    #nmap $(curl http://ipecho.net/plain)
    
    sudo systemctl start openvpn
    sudo journalctl -ea --no-pager
    systemctl list-units openvpn*
    curl http://ipecho.net/plain; echo;
    #nmap $(curl http://ipecho.net/plain)
    
    # avec un navigateur
        # http://ipecho.net/
        # https://www.purevpn.com/what-is-my-ip
        # https://ipleak.net/
        # https://whatismyipaddress.com/
    ## REMARQUE : les navigateurs disposent d'un cache DNS donc, avec WebRTC, 
    #             les serveurs DSN de la precedente configuration peuvent
    #             continuer d'apparaitre pendant un certain temps

## Wake On [Wireless] Lan (à titre d'exemple car le WOL ne fonctionne pas sur Raspberry Pi)

### Lectures

* [WOL](https://doc.ubuntu-fr.org/wakeonlan)
* 

### Activer le Wake on Wireless LAN de l'interface wl1

    iw phy phy$(iw dev wl1 info|grep wiphy|awk '{ print $2; }') wowlan enable any
    iw phy phy$(iw dev wl1 info|grep wiphy|awk '{ print $2; }') wowlan show

### Désactiver le Wake on Wireless LAN de l'interface wl1
    
    iw phy phy$(iw dev wl1 info|grep wiphy|awk '{ print $2; }') wowlan disable
    iw phy phy$(iw dev wl1 info|grep wiphy|awk '{ print $2; }') wowlan show

### Installer les outils pour le Wake On LAN

    apt-get -y install ethtool etherwake wakeonlan # tcpdump
    
### Vérifier la carte cible (ethernet)
   
    ethtool en0|grep "^\s\+Wake-on:"
    #ethtool -s en0 wol p
    #ethtool en0|grep "^\s\+Wake-on:"

    ###  Configurer la carte cible au demarrage
    #
    #EN0=$(ip -o -4 addr show|grep enx|awk '1==NR { print $2; }')
    #echo EN0=${EN0}
    #MAC=$(ifconfig ${EN0}|grep '\s\+ether '|awk '{ print $2; }')
    #echo MAC=${MAC}
    #echo "# /etc/network/interfaces.d/${EN0}
    #    auto ${EN0}
    #    iface ${EN0} inet dhcp
    #        up ethtool -s ${EN0} wol g
    #    " | sed -e "s|^        ||g" > /etc/network/interfaces.d/${EN0}
    #cat /etc/network/interfaces.d/${EN0}

### Tester la carte cible

    #// depuis la machine cible (compte 'root')
    tcpdump -i en0 port 9

## Kodi

    wget http://www.alelec.net/kodi/repository.alelec.zip
    wget http://cypher-media.com/repo/repository.Cypherslocker-1.0.6.zip
    wget http://archive.org/download/repository.xvbmc/repository.xvbmc-4.2.0.zip

## Arrêt/Relance Wifi/Bluetooth

    sudo rfkill block wifi
    sudo rfkill unblock wifi
    sudo rfkill block bluetooth
    sudo rfkill unblock bluetooth
