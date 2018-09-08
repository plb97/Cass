#  Cass


## Création d'une image 'Docker' pour Raspberry Pi 3 : PHP5 basée sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # php5
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/alpine:${TAG}
        
        PHP5_USER=apache
        PHP5_CONF_DIR=/etc/php5
        PHP5_CONF_VOL=${PHP5_CONF_DIR//\//-}
        APPLI=${APPLI}_${PHP5_USER}
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG PHP5_USER=apache
        
        ENV PHP5_USER=${PHP5_USER} \\
            PHP5_CONF_DIR=/etc/php5 \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            list=$(apk --no-cache search php5- | grep \'^php5-[[:alpha:]]\' | sed -e \'s|\\(^php5-.*\\)-[0-9].*|\\1|\') ; \\
            apk --no-cache add php5 ${list} ; \\
            unset list ; \\
            rc-update add php-fpm default; \\
            if [ -z $(grep "^${PHP5_USER}:" /etc/passwd) ]; then addgroup -S "${PHP5_USER}" ; adduser -S -D -g "${PHP5_USER}" ${PHP5_USER}; fi ; \\
            conf=${PHP5_CONF_DIR}/php-fpm.conf ; \\
            cp -v ${conf} ${conf}.origin ; rm -v ${conf} ; \\
            echo "; ${conf}" > ${conf} ; \\
            echo "[www]" >> ${conf} ; \\
            echo "pm = dynamic" >> ${conf} ; \\
            echo "pm.max_children = 5" >> ${conf} ; \\
            echo "pm.start_servers = 2" >> ${conf} ; \\
            echo "pm.min_spare_servers = 1" >> ${conf} ; \\
            echo "pm.max_spare_servers = 3" >> ${conf} ; \\
            echo "listen = /var/run/php-fpm5/www.sock" >> ${conf} ; \\
            echo "user = ${PHP5_USER}" >> ${conf} ; \\
            echo "group = ${PHP5_USER}" >> ${conf} ; \\
            echo "listen.owner = ${PHP5_USER}" >> ${conf} ; \\
            echo "listen.group = ${PHP5_USER}" >> ${conf} ; \\
            echo "listen.mode = 0666" >> ${conf} ; \\
            php-fpm5 -t ; \\
            unset conf ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${PHP5_CONF_DIR}
        
        ' | sed -e 's/^        //' > Dockerfile


### Construire l'image

    .  env.sh

    docker image build --force-rm --no-cache --build-arg "BASE=${BASE}" --build-arg "PHP5_USER=${PHP5_USER}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${PHP5_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${PHP5_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${PHP5_CONF_VOL}:${PHP5_CONF_DIR} \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// Verifier la version php
    docker container exec ${APPLI}_${TAG} php --version

    #// Consulter la configuration
    docker container exec ${APPLI}_${TAG} cat /etc/php5/php-fpm.conf

    #// Consulter le journal
    docker container exec ${APPLI}_${TAG} cat /var/log/php-fpm.log

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
    
    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; docker volume rm ${APPLI}${PHP5_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; docker volume rm ${APPLI}${PHP5_CONF_VOL} ; \
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest

### Nettoyer les images
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}
    docker image ls -a
    docker image save -o ${APPLI}.tar ${MAINTENER}/${APPLI}:${TAG}
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    docker image load -i ${APPLI}.tar ; docker image tag ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    rm -v ${APPLI}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a


