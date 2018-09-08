#  Cass

## Asterisk

### Installation avec un conteneur Docker 'Alpine'

        docker container start alpine
        docker container exec -it alpine bash
        
            apk --no-cache add asterisk asterisk-sample-config
            #// sauvegarder les fichiers de configuration d'origine
            LISTE="sip.conf users.conf extensions.conf"
            for f in ${LISTE}
            do
                echo /etc/asterisk/$f
                [ -f /etc/asterisk/$f.origin ] || cp -v /etc/asterisk/$f /etc/asterisk/$f.origin
            done
            for f in ${LISTE}
            do
                echo /etc/asterisk/$f
                grep '^[[:blank:]]*\([[:alpha:]]\|\[\)' /etc/asterisk/$f
                echo "============="
            done
            
    

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # asterisk
        VERS=alpine_3.8
        TAG=test
        NGINX_HTTP_PORT=80
        NGINX_HTTPS_PORT=443
        NGINX_NGINX_CONF_DIR=/etc/nginx
        NGINX_PHP7_CONF_DIR=/etc/php7
        NGINX_ROOT_DIR=/var/lib/nginx/html
        NGINX_NGINX_CONF_VOL=${NGINX_NGINX_CONF_DIR//\//-}
        NGINX_PHP7_CONF_VOL=${NGINX_PHP7_CONF_DIR//\//-}
        NGINX_ROOT_VOL=${NGINX_ROOT_DIR//\//-}
        ASTERISK_CONF_DIR=/etc/asterisk
        ASTERISK_CONF_VOL=${ASTERISK_CONF_DIR//\//-}
        ASTERISK_HTTP_PORT=$((3000 + ${NGINX_HTTP_PORT}))
        ASTERISK_HTTPS_PORT=$((3000 + ${NGINX_HTTPS_PORT}))
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh

    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG VERS
        FROM plb97/nginx:${VERS}
        
        ARG ASTERISK_CONF_DIR=/etc/asterisk
        
        RUN set -ex ; \\
            apk --no-cache add asterisk asterisk-sample-config asterisk-dahdi dahdi-linux perl ; \\
            addgroup -g $(ls -ld ${ASTERISK_CONF_DIR}|awk \'{print $4;}\') asterisk ; \\
            rc-update add asterisk default ; \\
            rc-update add dahdi default ; \\
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
            cp -v ${ASTERISK_CONF_DIR}/http.conf ${ASTERISK_CONF_DIR}/http.conf.origin ; \\
            sed -i -e \'s|^;enabled=yes|enabled=yes|\' -e \'s|^;enablestatic=yes|enablestatic=yes|\' -e \'s|^bindaddr=127.0.0.1|bindaddr=0.0.0.0|\' -e \'s|^;bindport=8088|bindport=8088|\' -e \'s|^;prefix=asterisk|prefix=asterisk|\' ${ASTERISK_CONF_DIR}/http.conf ; \\
            echo
        
        #RUN set -ex ; \\
        #    echo ";/etc/asterisk/guipreferences.conf" > /etc/asterisk/guipreferences.conf ; \\
        #    echo "config_upgraded = yes" >> /etc/asterisk/guipreferences.conf ; \\
        #    mkdir /usr/share/asterisk ; \\
        #    ln -s /var/lib/asterisk/static-http /usr/share/asterisk/static-http ; \\
        #    chown -R asterisk:asterisk /usr/share/asterisk ; \\
        #    #chmod 644 /etc/asterisk/* ; \\
        #    echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${ASTERISK_CONF_DIR}
        EXPOSE 5038
        EXPOSE 5060
        EXPOSE 8088
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --build-arg "VERS=${VERS}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_ROOT_VOL} ; \
    docker volume create ${APPLI}${ASTERISK_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${NGINX_NGINX_CONF_VOL}:${NGINX_NGINX_CONF_DIR} \
        -v ${APPLI}${NGINX_PHP7_CONF_VOL}:${NGINX_PHP7_CONF_DIR} \
        -v ${APPLI}${NGINX_ROOT_VOL}:${NGINX_ROOT_DIR} \
        -v ${APPLI}${ASTERISK_CONF_VOL}:${ASTERISK_CONF_DIR} \
        -p ${ASTERISK_HTTP_PORT}:${NGINX_HTTP_PORT} \
        -p ${ASTERISK_HTTPS_PORT}:${NGINX_HTTPS_PORT} \
        -p 5038:5038 \
        -p 5060:5060 \
        -p 8088:8088 \
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
    docker volume rm ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
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

