#  Cass


## FreePBX

    ### Lectures

* [FreePBX](https://wiki.freepbx.org/display/FOP/Version+14.0+Installation)
* [FreePBX](https://wiki.freepbx.org/display/FOP/Installing+FreePBX+14+on+Debian+8.8#InstallingFreePBX14onDebian8.8-InstallandConfigureFreePBX)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
    APPLI=$(basename $(pwd)) # freepbx
        MAINTENER=plb97
        VERS=alpine_3.8
        TAG=test
        PHP_VERS=5
        NGINX_HTTP_PORT=80
        NGINX_HTTPS_PORT=443
        NGINX_NGINX_CONF_DIR=/etc/nginx
        NGINX_PHP${PHP_VERS}_CONF_DIR=/etc/php${PHP_VERS}
        NGINX_ROOT_DIR=/var/lib/nginx
        NGINX_NGINX_CONF_VOL=${NGINX_NGINX_CONF_DIR//\//-}
        NGINX_PHP${PHP_VERS}_CONF_VOL=${NGINX_PHP${PHP_VERS}_CONF_DIR//\//-}
        NGINX_ROOT_VOL=${NGINX_ROOT_DIR//\//-}
        ASTERISK_CONF_DIR=/etc/asterisk
        ASTERISK_CONF_VOL=${ASTERISK_CONF_DIR//\//-}
        FREEPBX_HTTP_PORT=$((4000 + ${NGINX_HTTP_PORT}))
        FREEPBX_HTTPS_PORT=$((4000 + ${NGINX_HTTPS_PORT}))
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh

    .  env.sh

### Créer le fichier 'freepbx.list' 

    .  env.sh

    echo $'amd
        announcement
        api
        arimanager
        asterisk-cli
        asteriskinfo
        backup
        blacklist
        bulkhandler
        calendar
        callback
        callforward
        callrecording
        callwaiting
        campon
        cdr
        cel
        certman
        cidlookup
        conferences
        configedit
        contactdir
        contactmanager
        core
        customappsreg
        cxpanel
        dahdiconfig
        dashboard
        daynight
        devtools
        dictate
        digium_phones
        digiumaddoninstaller
        directory
        disa
        donotdisturb
        dundicheck
        extensionsettings
        fax
        featurecodeadmin
        filestore
        findmefollow
        firewall
        framework
        freepbxlocalization
        fw_langpacks
        hotelwakeup
        iaxsettings
        infoservices
        ivr
        languages
        logfiles
        manager
        miscapps
        miscdests
        motif
        music
        outroutemsg
        paging
        parking
        pbdirectory
        phonebook
        pinsets
        pm2
        presencestate
        printextensions
        queueprio
        queues
        recordings
        restart
        ringgroups
        setcid
        sipsettings
        soundlang
        speeddial
        superfecta
        timeconditions
        tts
        ttsengines
        ucp
        userman
        vmblast
        voicemail
        weakpasswords
        webrtc
        xmpp
        ' | sed -e 's/^        //' > ${APPLI}.list

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG VERS
        FROM plb97/nginx:${VERS}
        
        COPY freepbx.list /root
        
        ARG ASTERISK_CONF_DIR=/etc/asterisk
        
        RUN set -ex ; \\
            apk --no-cache add git asterisk asterisk-sample-config asterisk-dahdi dahdi-linux ; \\
            addgroup -g $(ls -ld ${ASTERISK_CONF_DIR}|awk \'{print $4;}\') asterisk ; \\
            rc-update add asterisk default ; \\
            echo
        
        RUN set -ex ; \\
            cp -v ${ASTERISK_CONF_DIR}/manager.conf ${ASTERISK_CONF_DIR}/manager.conf.origin ; \\
            sed -i -e \'s|^enabled = no|enabled = yes|\' -e \'s|^;webenabled = yes|webenabled = yes|\' ${ASTERISK_CONF_DIR}/manager.conf ; \\
            echo "[pi]" >> ${ASTERISK_CONF_DIR}/manager.conf ; \\
            echo "secret = raspbian" >> ${ASTERISK_CONF_DIR}/manager.conf ; \\
            echo "read = system,call,log,verbose,command,agent,user,originate" >> ${ASTERISK_CONF_DIR}/manager.conf ; \\
            echo "write = system,call,log,verbose,command,agent,user,originate" >> ${ASTERISK_CONF_DIR}/manager.conf ; \\
            echo
        
        RUN set -ex ; \\
            echo "#!/sbin/openrc-run" > /etc/init.d/firstrun ; \\
            echo "" >> /etc/init.d/firstrun ; \\
            echo "description=\\"Cloning FreePBX.\\"" >> /etc/init.d/firstrun ; \\
            echo "" >> /etc/init.d/firstrun ; \\
            echo "start() {" >> /etc/init.d/firstrun ; \\
            echo "    ebegin \\"Cloning FreePBX\\"" >> /etc/init.d/firstrun ; \\
            echo "    cd /root >> /etc/init.d/firstrun ; \\
            echo "    mkdir freepbx" >> /etc/init.d/firstrun ; \\
            echo "    cd freepbx" >> /etc/init.d/firstrun ; \\
            echo "    for f in \$(cat /root/freepbx.list); do git clone https://github.com/FreePBX/\$f; done" >> /etc/init.d/firstrun ; \\
            echo "    rc-update del firstrun" >> /etc/init.d/firstrun ; \\
            echo "    eend \$?" >> /etc/init.d/firstrun ; \\
            echo "}" >> /etc/init.d/firstrun ; \\
            chmod +x /etc/init.d/firstrun ; \\
            rc-update add firstrun default ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${ASTERISK_CONF_DIR}
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --build-arg "VERS=${VERS}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_PHP${PHP_VERS}_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_ROOT_VOL} ; \
    docker volume create ${APPLI}${ASTERISK_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${NGINX_NGINX_CONF_VOL}:${NGINX_NGINX_CONF_DIR} \
        -v ${APPLI}${NGINX_PHP${PHP_VERS}_CONF_VOL}:${NGINX_PHP${PHP_VERS}_CONF_DIR} \
        -v ${APPLI}${NGINX_ROOT_VOL}:${NGINX_ROOT_DIR} \
        -v ${APPLI}${ASTERISK_CONF_VOL}:${ASTERISK_CONF_DIR} \
        -p ${FREEPBX_HTTP_PORT}:${NGINX_HTTP_PORT} \
        -p ${FREEPBX_HTTPS_PORT}:${NGINX_HTTPS_PORT} \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it ${APPLI}_${TAG} sh

    #// arreter le conteneur
    docker container stop ${APPLI}_${TAG}

    #// demarrer le conteneur
    docker container start ${APPLI}_${TAG}

    #// redemarrer le conteneur
    docker container restart ${APPLI}_${TAG}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}

    docker volume rm ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_PHP${PHP_VERS}_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_ROOT_VOL} ; \
    docker volume rm ${APPLI}${ASTERISK_CONF_VOL}


### Nettoyer les images
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}
    docker image ls -a 
    docker image save -o ${APPLI}.tar ${MAINTENER}/${APPLI}:${TAG}
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    docker image ls -a
    docker image load -i ${APPLI}.tar
    docker image ls -a
    rm -v ${APPLI}.tar
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a

