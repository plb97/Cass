#  Cass

## Créer un NAS avec un disque externe USB

### Lectures

* [NAS](https://raspbian-france.fr/raspberry-pi-nas-samba/)
*

    #// passer 'root'
    sudo -i

        mount
        #// creer le repertoire 'public'
        mkdir ${DIR}/public
        chown -R root:users ${DIR}/public
        chmod -R ug=rwx,o=rx ${DIR}/public
        #// creer le lien 'cdrom'
        ln -s /media/cdrom
        #// creer des comptes utilisateurs (facultatf)
        LISTE="" # a definir
        echo LISTE=${LISTE}
        GROUPE=users
        echo GROUPE=${GROUPE}
        for COMPTE in ${LISTE}; do adduser --disabled-login --disabled-password --home ${DIR}/${COMPTE} ${COMPTE}; usermod -aG ${GROUPE} ${COMPTE}; done
        #// installer 'samba'
        apt install samba samba-common-bin
        #// configurer 'samba'
        nano /etc/samba/smb.conf
        #// apres la ligne '##### Authentification #####' ajouter
        security = user
        #// dans la rubrique '[homes]' forcer
        read only = no
        #// enfin de fichier ajouter la rubrique
        [public]
        comment = Public Storage
        path = /home/shares/public
        valid users = @users
        force group = users
        create mask = 0660
        directory mask = 0771
        read only = no

        [cdrom]
        comment = Public Cdrom
        path = /home/shares/cdrom
        valid users = @users
        read only = yes

        #// sortir du fichier en le sauvegardant
        #// ajouter l'utilisateur 'pi' a 'samba' et saisir le mot de passs lorsque demande
        smbpasswd -a pi
        #// ajouter les autres utilisateurs a 'samba' et saisir le mot de passs lorsque demande (facultatif)
        for COMPTE in ${LISTE}; do echo ${COMPTE}; smbpasswd -a ${COMPTE}; done

        #// relancer 'samba'
        /etc/init.d/samba restart
        #// si c'est correct relancer le systeme
        reboot

