#  Cass


## Kodi et Omxplayer

### Lectures

* [OmxPlayer](https://elinux.org/Omxplayer)
*

Voir [*Montage automatique disques USB ou DVD*](RASPBERRYPI3.md)

    #// passer 'root'
    sudo -i
        #// declarer les cles d'activation des licences videos
        MPG2=<votre clé MPG2>
        WVC1=<votre clé WVC1>
        echo "decode_MPG2=${MPG2}" >> /boot/config.txt
        echo "decode_WVC1=${WVC1}" >> /boot/config.txt
        #// redemarrer
        reboot

Installation de 'Kodi'.

    #// verifier les licences
    vcgencmd codec_enabled MPG2
    vcgencmd codec_enabled WVC1

    #// mettre a jour l'installation
    sudo apt-get update
    sudo apt-get upgrade

    #// installer 'Kodi'
    sudo apt-get install kodi`
    #// lancer 'Kodi'
    kodi
    #// choisir 'Disc' ou 'Disque' dans le menu...
    #// verifier que 'Disc' ou 'Disque' disparait apres l'ejection du DVD et reapparait apres la reinsertion du DVD


Installation de 'Omxplayer'.

    #// passer 'root'
    sudo -i
        apt-get install omxplayer fonts-freefont-ttf
        echo 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' > /etc/udev/rules.d/10-vchiq-permissions.rules
        usermod -aGvideo pi
        exit

    #// redemarrer
    sudo reboot
