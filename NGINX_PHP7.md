#  Raspberry Pi / Docker

## Nginx basée sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # nginx-php7
        BASE=${MAINTENER}/alpine
        
        NGINX_HTTP_PORT=80
        NGINX_ROOT_DIR=/var/lib/nginx/html
        NGINX_ROOT_VOL=${APPLI}${NGINX_ROOT_DIR//\//-}
        
        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${MAINTENER}_${APPLI}
        COMMANDE=""
        ' | sed -e 's/^        //' | tee env.sh
    chmod +x env.sh
    .  env.sh




    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # nginx
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/php7_nginx:${TAG}
        
        NGINX_HTTP_PORT=80
        NGINX_HTTPS_PORT=443
        NGINX_NGINX_CONF_DIR=/etc/nginx
        NGINX_ROOT_DIR=/var/lib/nginx
        NGINX_PHP7_CONF_DIR=/etc/php7
        NGINX_NGINX_CONF_VOL=${NGINX_NGINX_CONF_DIR//\//-}
        NGINX_ROOT_VOL=${NGINX_ROOT_DIR//\//-}
        NGINX_PHP7_CONF_VOL=${NGINX_PHP7_CONF_DIR//\//-}
        
        APPLI=${APPLI}_php7
        CONETEUR=${APPLI}_${TAG}
        IMAGE=${MAINTENER}/${APPLI}
        ' | sed -e 's/^        //' | tee env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG PHP7_USER=nginx
        
        ENV PHP7_USER=${PHP7_USER} \\
            PHP7_CONF_DIR=/etc/php7 \\
            NGINX_ROOT_DIR=/var/lib/nginx/html \\
            NGINX_NGINX_CONF_DIR=/etc/nginx \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            list=$(apk --no-cache search php7- \\
            | grep \'^php7-[[:alpha:]]\' \\
            | sed -e \'s|\\(^php7-.*\\)-[0-9].*|\\1|\' \\
            | grep -v -e \'apache2\' -e \'gmagick\' \\
            ) ; \\
            apk --no-cache add php7 ${list} nginx; \\
            unset list ; \\
            if [ -z $(grep "^${PHP7_USER}:" /etc/passwd) ]; then addgroup -S "${PHP7_USER}" ; adduser -S -D -g "${PHP7_USER}" ${PHP7_USER}; fi ; \\
            php_conf=${PHP7_CONF_DIR}/php-fpm.d/www.conf ; \\
            cp -v ${php_conf} ${php_conf}.origin ; rm -v ${php_conf} ; \\
            { \\
            echo "; ${php_conf}" ; \\
            echo "[www]" ; \\
            echo "pm = dynamic" ; \\
            echo "pm.max_children = 5" ; \\
            echo "pm.start_servers = 2" ; \\
            echo "pm.min_spare_servers = 1" ; \\
            echo "pm.max_spare_servers = 3" ; \\
            echo "listen = /var/run/php-fpm7/www.sock" ; \\
            echo "user = ${PHP7_USER}" ; \\
            echo "group = ${PHP7_USER}" ; \\
            echo "listen.owner = ${PHP7_USER}" ; \\
            echo "listen.group = ${PHP7_USER}" ; \\
            echo "listen.mode = 0666" ; \\
            } > ${php_conf} ; \\
            cat ${php_conf} ; \\
            unset php_conf ; \\
            php-fpm7 -t ; \\
            rc-update add php-fpm7 default; \\
            # Creation de la configuration par defaut
            default_conf="${NGINX_NGINX_CONF_DIR}/conf.d/default.conf" ; \\
            mv -v ${default_conf} ${default_conf}.origin ; \\
            { \\
            echo "# ${default_conf}" >> ${default_conf} ; \\
            echo "error_log /var/log/nginx/error.log warn;" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "server {" >> ${default_conf} ; \\
            echo "    include ${NGINX_NGINX_CONF_DIR}/mime.types;" >> ${default_conf} ; \\
            echo "    default_type application/octet-stream;" >> ${default_conf} ; \\
            echo "    access_log /var/log/nginx/access.log;" >> ${default_conf} ; \\
            echo "    keepalive_timeout 3000;" >> ${default_conf} ; \\
            echo "    listen 80 default_server;" >> ${default_conf} ; \\
            echo "    listen [::]:80 default_server;" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "    location / {" >> ${default_conf} ; \\
            echo "        root ${NGINX_ROOT_DIR}/html;" >> ${default_conf} ; \\
            echo "        index index.php index.html index.htm;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "" >> ${default_conf} ; \\
            echo "    location ~ \.php$ {" >> ${default_conf} ; \\
            echo "        include fastcgi.conf;" >> ${default_conf} ; \\
            echo "        fastcgi_index index.php;" >> ${default_conf} ; \\
            echo "        fastcgi_pass unix:/var/run/php-fpm7/www.sock;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "    location = /50x.html {" >> ${default_conf} ; \\
            echo "        root ${NGINX_ROOT_DIR};" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "    location = /404.html {" >> ${default_conf} ; \\
            echo "        internal;" >> ${default_conf} ; \\
            echo "    }" >> ${default_conf} ; \\
            echo "}" >> ${default_conf} ; \\
            } > ${default_conf} ; \\
            cat ${default_conf} ; \\
            unset default_conf ; \\
            # Creation d\'une page d\'informations sur PHP
            phpinfo=${NGINX_ROOT_DIR}/phpinfo.php ; \\
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
            mkdir /run/nginx ; \\
            nginx -t ; \\
            rc-update add nginx default ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        EXPOSE 80
        VOLUME VOLUME ${PHP7_CONF_DIR} ${NGINX_NGINX_CONF_DIR} ${NGINX_ROOT_DIR}

        ' | sed -e 's/^        //' | tee Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Créer les volumes

    docker volume create ${APPLI}${NGINX_ROOT_VOL} ; docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${NGINX_ROOT_VOL} ; \
    docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
    docker container run \
        --name ${CONTENEUR} \
        --tmpfs /run \
        --tmpfs /run/lock \
        --tmpfs /tmp \
        -v /sys/fs/cgroup \
        -p 20080:80 \
        -d ${IMAGE}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps

    #// Consulter les ports qui ecoutent
    docker container exec ${CONTENEUR} netstat -lt

    #// Consulter la configuration
    docker container exec ${CONTENEUR} cat ${NGINX_PHP7_CONF_DIR}/php-fpm.d/www.conf

    #// Consulter les journaux
    docker container exec ${CONTENEUR} cat /var/log/php7/error.log ; \
    docker container exec ${CONTENEUR} cat /var/log/nginx/error.log

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it ${CONTENEUR} sh

    #// arreter le conteneur
    docker container stop ${CONTENEUR}

    #// demarrer le conteneur
    docker container start ${CONTENEUR}

    #// redemarrer le conteneur
    docker container restart ${CONTENEUR}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker volume rm ${APPLI}${NGINX_ROOT_VOL} ; \
    docker volume rm ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_PHP7_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker image rm ${IMAGE}

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a 
    docker image save -o ${IMAGE}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i ${IMAGE}.tar ; docker image tag ${IMAGE}
    rm -v ${IMAGE}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a


