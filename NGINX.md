#  Cass

## Création d'une image 'Docker' pour Raspberry Pi 3 : Nginx basée sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # nginx
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/php7_nginx:${TAG}
        
        NGINX_HTTP_PORT=80
        NGINX_HTTPS_PORT=443
        NGINX_NGINX_CONF_DIR=/etc/nginx
        NGINX_DATA_DIR=/var/lib/nginx
        NGINX_PHP7_CONF_DIR=/etc/php7
        NGINX_NGINX_CONF_VOL=${NGINX_NGINX_CONF_DIR//\//-}
        NGINX_DATA_VOL=${NGINX_DATA_DIR//\//-}
        NGINX_PHP7_CONF_VOL=${NGINX_PHP7_CONF_DIR//\//-}
        
        APPLI=${APPLI}_php7
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ENV NGINX_DATA_DIR=/var/lib/nginx \\
            NGINX_NGINX_CONF_DIR=/etc/nginx \\
            NGINX_HTTP_PORT=80 \\
            NGINX_HTTPS_PORT=443 \\
            NGINX_PHP7_CONF_DIR=/etc/php7 \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            # Installation de nginx
            apk --no-cache add nginx ; \\
            mkdir /run/nginx ; \\
            # Creation de la configuration par defaut
            default_conf="${NGINX_NGINX_CONF_DIR}/conf.d/default.conf" ; \\
            mv -v ${default_conf} ${default_conf}.origin ; \\
            touch ${default_conf} ; \\
            echo "# ${default_conf}" >> ${default_conf} ; \\
            echo "error_log /var/log/nginx/error.log warn;" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "server {" >> ${default_conf} ; \\
            echo "    include ${NGINX_NGINX_CONF_DIR}/mime.types;" >> ${default_conf} ; \\
            echo "    default_type application/octet-stream;" >> ${default_conf} ; \\
            echo "    access_log /var/log/nginx/access.log;" >> ${default_conf} ; \\
            echo "    keepalive_timeout 3000;" >> ${default_conf} ; \\
            echo "    listen ${NGINX_HTTP_PORT} default_server;" >> ${default_conf} ; \\
            echo "    listen [::]:${NGINX_HTTP_PORT} default_server;" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "    location / {" >> ${default_conf} ; \\
            echo "        root ${NGINX_DATA_DIR}/html;" >> ${default_conf} ; \\
            echo "        index index.php index.html index.htm;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "    location ~ \.php$ {" >> ${default_conf} ; \\
            echo "        include fastcgi.conf;" >> ${default_conf} ; \\
            echo "        fastcgi_index index.php;" >> ${default_conf} ; \\
            echo "        fastcgi_pass unix:/var/run/php-fpm7/www.sock;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "    location = /50x.html {" >> ${default_conf} ; \\
            echo "        root ${NGINX_DATA_DIR}/html;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "    location = /404.html {" >> ${default_conf} ; \\
            echo "        internal;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "}" >> ${default_conf} ; \\
            unset default_conf ; \\
            # Creation d\'une page d\'informations sur PHP
            phpinfo=${NGINX_DATA_DIR}/html/phpinfo.php ; \\
            echo "<?php" > ${phpinfo} ; \\
            echo "" >> ${phpinfo} ; \\
            echo "// Affiche toutes les informations, comme le ferait INFO_ALL" >> ${phpinfo} ; \\
            echo "phpinfo();" >> ${phpinfo} ; \\
            echo "" >> ${phpinfo} ; \\
            echo "// Affiche uniquement le module d\'information." >> ${phpinfo} ; \\
            echo "// phpinfo(8) fournirait les mêmes informations." >> ${phpinfo} ; \\
            echo "phpinfo(INFO_MODULES);" >> ${phpinfo} ; \\
            echo "" >> ${phpinfo} ; \\
            echo "?>" >> ${phpinfo} ; \\
            unset phpinfo ; \\
            # Vérification de la configuration de nginx
            nginx -t ; \\
            rc-update add nginx default ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        EXPOSE ${NGINX_HTTP_PORT}
        EXPOSE ${NGINX_HTTPS_PORT}
        
        VOLUME ${NGINX_NGINX_CONF_DIR}
        VOLUME ${NGINX_PHP7_CONF_DIR}
        VOLUME ${NGINX_DATA_DIR}

        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${NGINX_DATA_VOL} ; docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${NGINX_DATA_VOL} ; \
    docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${NGINX_DATA_VOL}:${NGINX_DATA_DIR} \
        -v ${APPLI}${NGINX_NGINX_CONF_VOL}:${NGINX_NGINX_CONF_DIR} \
        -v ${APPLI}${NGINX_PHP7_CONF_VOL}:${NGINX_PHP7_CONF_DIR} \
        -p ${NGINX_HTTP_PORT}:80 \
        -p ${NGINX_HTTPS_PORT}:443 \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// Consulter les ports qui ecoutent
    docker container exec ${APPLI}_${TAG} netstat -l

    #// Consulter la configuration
    docker container exec ${APPLI}_${TAG} cat ${NGINX_PHP7_CONF_DIR}/php-fpm.d/www.conf

    #// Consulter les journaux
    docker container exec ${APPLI}_${TAG} cat /var/log/php7/error.log ; \
    docker container exec ${APPLI}_${TAG} cat /var/log/nginx/error.log

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
    
    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${NGINX_DATA_VOL} ; \
    docker volume rm ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_PHP7_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
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


