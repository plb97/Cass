#  Cass


## Création d'une image 'Docker' pour Raspberry Pi 3 : PHP7 basée sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # php7
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/alpine:${TAG}
        
        PHP7_USER=nginx
        PHP7_CONF_DIR=/etc/php7
        PHP7_CONF_VOL=${PHP7_CONF_DIR//\//-}
        APPLI=${APPLI}_${PHP7_USER}
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG PHP7_USER=nginx
        
        ENV PHP7_USER=${PHP7_USER} \\
            PHP7_CONF_DIR=/etc/php7 \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            list=$(apk --no-cache search php7- | grep \'^php7-[[:alpha:]]\' | sed -e \'s|\\(^php7-.*\\)-[0-9].*|\\1|\') ; \\
            apk --no-cache add php7 ${list}; \\
            unset list ; \\
            rc-update add php-fpm7 default; \\
            if [ -z $(grep "^${PHP7_USER}:" /etc/passwd) ]; then addgroup -S "${PHP7_USER}" ; adduser -S -D -g "${PHP7_USER}" ${PHP7_USER}; fi ; \\
            php_conf=${PHP7_CONF_DIR}/php-fpm.d/www.conf ; \\
            cp -v ${php_conf} ${php_conf}.origin ; rm -v ${php_conf} ; \\
            touch ${php_conf} ; \\
            echo "; ${php_conf}" >> ${php_conf} ; \\
            echo "[www]" >> ${php_conf} ; \\
            echo "pm = dynamic" >> ${php_conf} ; \\
            echo "pm.max_children = 5" >> ${php_conf} ; \\
            echo "pm.start_servers = 2" >> ${php_conf} ; \\
            echo "pm.min_spare_servers = 1" >> ${php_conf} ; \\
            echo "pm.max_spare_servers = 3" >> ${php_conf} ; \\
            echo "listen = /var/run/php-fpm7/www.sock" >> ${php_conf} ; \\
            echo "user = ${PHP7_USER}" >> ${php_conf} ; \\
            echo "group = ${PHP7_USER}" >> ${php_conf} ; \\
            echo "listen.owner = ${PHP7_USER}" >> ${php_conf} ; \\
            echo "listen.group = ${PHP7_USER}" >> ${php_conf} ; \\
            echo "listen.mode = 0666" >> ${php_conf} ; \\
            php-fpm7 -t ; \\
            unset php_conf ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${PHP7_CONF_DIR}
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --force-rm --no-cache --build-arg "BASE=${BASE}" --build-arg "PHP7_USER=${PHP7_USER}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${PHP7_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${PHP7_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} -v ${APPLI}${PHP7_CONF_VOL}:${PHP7_CONF_DIR} -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// Verifier la version php
    docker container exec ${APPLI}_${TAG} php --version

    #// Consulter la configuration
    docker container exec ${APPLI}_${TAG} cat /etc/php7/php-fpm.d/www.conf

    #// Consulter le journal
    docker container exec ${APPLI}_${TAG} cat /var/log/php7/error.log

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
    
    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; docker volume rm ${APPLI}${PHP7_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${PHP7_CONF_VOL} ; \
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


