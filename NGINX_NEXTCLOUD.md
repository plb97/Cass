#  Raspberry Pi / Docker

## Nextcloud/Nginx basée sur Alpine

### Lectures

* [config](https://docs.nextcloud.com/server/15/admin_manual/installation/nginx.html)
* [...](https://wiki.alpinelinux.org/wiki/Nextcloud#Nginx)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        BASE=${MAINTENER}/alpine
        #APPLI=$(basename $(pwd)) # nginx-nextcloud
        APPLI=nextcloud
        PORT=40800
        
        NC_HTTP_PORT=$((80+$PORT))
        NC_PHP7_CONF_DIR=/etc/php7
        NC_NGINX_CONF_DIR=/etc/nginx
        NC_NGINX_LOG_DIR=/var/log/nginx
        NC_HTML_DIR=/var/lib/nginx/html
        NC_CONF_DIR=/etc/nextcloud
        NC_LOG_DIR=/var/log/nextcloud
        NC_DATA_DIR=/var/lib/nextcloud/data
        
        NC_DATA_VOL=${APPLI}${NC_DATA_DIR//\//-}
        NC_LOG_VOL=${APPLI}${NC_LOG_DIR//\//-}
        NC_HTML_VOL=${APPLI}${NC_HTML_DIR//\//-}
        NC_CONF_VOL=${APPLI}${NC_CONF_DIR//\//-}
        NC_PHP7_CONF_VOL=${APPLI}${NC_PHP7_CONF_DIR//\//-}
        NC_PHP7_USER=nginx
        NC_NGINX_CONF_VOL=${APPLI}${NC_NGINX_CONF_DIR//\//-}
        
        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${MAINTENER}_${APPLI}
        COMMANDE=""
        echo BASE=${BASE}
        echo APPLI=${APPLI}
        set|grep "^NC_"
        ' | sed -e 's/^        //' | tee env.sh

    chmod +x env.sh
    .  env.sh


### Créer le fichier 'www.conf' 

    echo "; ${NC_PHP7_CONF_DIR}/php-fpm.d/www.conf
        [www]
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        listen = /var/run/php-fpm7/www.sock
        user = ${NC_PHP7_USER}
        group = ${NC_PHP7_USER}
        listen.owner = ${NC_PHP7_USER}
        listen.group = ${NC_PHP7_USER}
        listen.mode = 0666
        " | sed -e 's/^        //' | tee www.conf


### Créer le fichier 'default.conf' 

    echo "# ${NC_NGINX_CONF_DIR}/conf.d/default.conf

        root ${NC_HTML_DIR};
        access_log ${NC_NGINX_LOG_DIR}/access.log;
        error_log ${NC_NGINX_LOG_DIR}/error.log warn;

        upstream php-handler {
            server unix:/var/run/php-fpm7/www.sock;
        }
        server {
            include ${NC_NGINX_CONF_DIR}/mime.types;
            default_type application/octet-stream;
            access_log ${NC_NGINX_LOG_DIR}/access.log;
            keepalive_timeout 3000;
            listen 80 default_server;
            listen [::]:80 default_server;
            disable_symlinks off;
            fastcgi_hide_header X-Powered-By;
            # set max upload size
            client_max_body_size 10G;
            # Syntax:     fastcgi_buffers number size;
            # Default:    fastcgi_buffers 8 4k|8k;
            # Context:    http, server, location
            fastcgi_buffers 64 8k;
            ###fastcgi_buffers 64 400M;
            # Syntax:     fastcgi_busy_buffers_size size;
            # Default:    fastcgi_busy_buffers_size 8k|16k;
            # Context:    http, server, location
            fastcgi_busy_buffers_size 16k;
            location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
            }

            location = /.well-known/carddav {
              return 301 \$scheme://\$host:\$server_port/nextcloud/remote.php/dav;
            }
            location = /.well-known/caldav {
              return 301 \$scheme://\$host:\$server_port/nextcloud/remote.php/dav;
            }
            location /.well-known/acme-challenge { }

            location ^~ /nextcloud {
                access_log ${NC_NGINX_LOG_DIR}/nextcloud_access.log;
                error_log ${NC_NGINX_LOG_DIR}/nextcloud_error.log warn;

                # Enable gzip but do not remove ETag headers
                gzip on;
                gzip_vary on;
                gzip_comp_level 4;
                gzip_min_length 256;
                gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
                gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

                location /nextcloud {
                    rewrite ^ /nextcloud/index.php;
                }

                location ~ ^\/nextcloud\/(?:build|tests|config|lib|3rdparty|templates|data)\/ {
                    deny all;
                }
                location ~ ^\/nextcloud\/(?:\.|autotest|occ|issue|indie|db_|console) {
                    deny all;
                }

                location ~ ^\/nextcloud\/(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+)\.php(?:\$|\/) {
                    fastcgi_split_path_info ^(.+?\.php)(\/.*|)\$;
                    set \$path_info \$fastcgi_path_info;
                    try_files \$fastcgi_script_name =404;
                    include fastcgi_params;
                    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                    fastcgi_param PATH_INFO \$path_info;
                    ## fastcgi_param HTTPS on;
                    # Avoid sending the security headers twice
                    fastcgi_param modHeadersAvailable true;
                    # Enable pretty urls
                    fastcgi_param front_controller_active true;
                    fastcgi_pass php-handler;
                    fastcgi_intercept_errors on;
                    fastcgi_request_buffering off;
                }

                location ~ ^\/nextcloud\/(?:updater|oc[ms]-provider)(?:\$|\/) {
                    try_files \$uri/ =404;
                    index index.php;
                }

                # Adding the cache control header for js, css and map files
                # Make sure it is BELOW the PHP block
                location ~ ^\/nextcloud\/.+[^\/]\.(?:css|js|woff2?|svg|gif|map)\$ {
                    try_files \$uri /nextcloud/index.php\$request_uri;
                    add_header Cache-Control \"public, max-age=15778463\";
                    # Add headers to serve security related headers  (It is intended
                    # to have those duplicated to the ones above)
                    # Before enabling Strict-Transport-Security headers please read
                    # into this topic first.
                    #add_header Strict-Transport-Security \\\"max-age=15768000; includeSubDomains; preload;\\\";
                    #
                    # WARNING: Only add the preload option once you read about
                    # the consequences in https://hstspreload.org/. This option
                    # will add the domain to a hardcoded list that is shipped
                    # in all major browsers and getting removed from this list
                    # could take several months.
                    add_header X-Content-Type-Options nosniff;
                    add_header X-XSS-Protection \"1; mode=block\";
                    add_header X-Robots-Tag none;
                    add_header X-Download-Options noopen;
                    add_header X-Permitted-Cross-Domain-Policies none;
                    add_header Referrer-Policy no-referrer;
            
                    # Optional: Don\'t log access to assets
                    access_log off;
                }

                location ~ ^\/nextcloud\/.+[^\/]\.(?:png|html|ttf|ico|jpg|jpeg|bcmap)\$ {
                    try_files \$uri /nextcloud/index.php\$request_uri;
                    # Optional: Don\'t log access to other assets
                    access_log off;
                }

            }

            location ~ /.+\.php\$ {
                include fastcgi.conf;
                fastcgi_index index.php;
                fastcgi_pass php-handler;
            }

            location / {
                index index.php index.html index.htm;
            }

            location = /50x.html {
                root ${NC_HTML_DIR};
            }

            location = /404.html {
                internal;
            }
        }
        " | sed -e 's/^        //' | tee default.conf


### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG NC_PHP7_USER
        ARG NC_PHP7_CONF_DIR
        ARG NC_DATA_DIR
        ARG NC_HTML_DIR
        ARG NC_CONF_DIR
        ARG NC_LOG_DIR
        ARG NC_DATA_DIR
        ARG NC_NGINX_CONF_DIR
        ARG NC_NGINX_LOG_DIR
        
        ENV PHP7_USER=${PHP7_USER:-nginx} \\
            NC_PHP7_CONF_DIR=${NC_PHP7_CONF_DIR:-/etc/php7} \\
            NC_PHP7_USER=${NC_PHP7_USER:-nginx} \\
            NC_HTML_DIR=${NC_HTML_DIR:-/var/lib/nginx/html} \\
            NC_CONF_DIR=${NC_CONF_DIR:-/etc/nextcloud} \\
            NC_LOG_DIR=${NC_LOG_DIR:-/var/log/nextcloud} \\
            NC_DATA_DIR=${NC_DATA_DIR:-/var/lib/nextcloud/data} \\
            NC_NGINX_CONF_DIR=${NC_NGINX_CONF_DIR:-/etc/nginx} \\
            NC_NGINX_LOG_DIR=${NC_NGINX_LOG_DIR:-/var/log/nginx} \\
            LANG=C.UTF-8
        #
        # Installation des paquets
        #
        RUN set -ex ; \\
            #list=$(apk --no-cache search php7- \\
            #| grep \'^php7-[[:alpha:]]\' \\
            #| sed -e \'s|\\(^php7-.*\\)-[0-9].*|\\1|\' \\
            #| grep -v -e \'apache2\' -e \'gmagick\' \\
            #) ; \\
            #list= ; \\
            list="php7-ctype php7-curl php7-dom php7-fpm php7-gd php7-iconv php7-json php7-mbstring php7-openssl php7-posix php7-session php7-simplexml php7-xml php7-xmlreader php7-xmlwriter php7-zip" ; \\
            apk --no-cache add php7 ${list} nginx ; \\
            unset list ; \\
            if [ -z $(grep "^${NC_PHP7_USER}:" /etc/passwd) ]; then addgroup -S "${NC_PHP7_USER}" ; adduser -S -D -g "${NC_PHP7_USER}" ${NC_PHP7_USER}; fi ; \\
            echo paquets installés
        #
        # Installation fichier www.conf
        #
        COPY ./www.conf /root/
        RUN set -ex ; \\
            php_conf=${NC_PHP7_CONF_DIR}/php-fpm.d/www.conf ; \\
            cp -v ${php_conf} ${php_conf}.origin ; rm -v ${php_conf} ; \\
            mv -v /root/www.conf ${php_conf} ; \\
            cat ${php_conf} ; \\
            unset php_conf ; \\
            #
            # Vérification de la configuration de php
            #
            php-fpm7 -t ; \\
            rc-update add php-fpm7 default ; \\
            echo fichier www.conf installé
        #
        # Creation de la configuration par defaut
        #
        COPY ./default.conf /root/
        RUN set -ex ; \\
            default_conf="${NC_NGINX_CONF_DIR}/conf.d/default.conf" ; \\
            mv -v ${default_conf} ${default_conf}.origin ; \\
            mv -v /root/default.conf ${default_conf} ; \\
            cat ${default_conf} ; \\
            unset default_conf ; \\
            #
            # Vérification de la configuration de nginx
            #
            mkdir /run/nginx ; \\
            nginx -t ; \\
            rc-update add nginx default ; \\
            echo fichier default.conf installé
        #
        # Installation de Nextcloud
        #
        RUN set -ex ; \\
            #list=$(apk --no-cache search nextcloud- \\
            #| grep \'^nextcloud-[[:alpha:]]\' \\
            #| sed -e \'s|\\(^nextcloud-.*\\)-[0-9].*|\\1|\' \\
            #| grep -v -e \'mysql\' -e \'pgsql\' \\
            #) ; \\
            #list= ; \\
            list="nextcloud-sqlite" ; \\
            apk --no-cache add nextcloud ${list} ; \\
            unset list ; \\
            ln -s /usr/share/webapps/nextcloud ${NC_HTML_DIR}/nextcloud ; \\
            echo nextcloud installé
        
        ENTRYPOINT ["/sbin/openrc-init"]
        EXPOSE 80
        VOLUME ${NC_DATA_DIR} ${NC_LOG_DIR} ${NC_HTML_DIR} ${NC_CONF_DIR} ${NC_PHP7_CONF_DIR} ${NC_NGINX_CONF_DIR}

        ' | sed -e 's/^        //' | tee Dockerfile


### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Créer les volumes

    docker volume create ${NC_DATA_VOL}
    docker volume create ${NC_LOG_VOL}
    docker volume create ${NC_HTML_VOL}
    docker volume create ${NC_CONF_VOL}
    docker volume create ${NC_PHP7_CONF_VOL}
    docker volume create ${NC_NGINX_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${NC_DATA_VOL}
    docker volume create ${NC_LOG_VOL}
    docker volume create ${NC_HTML_VOL}
    docker volume create ${NC_CONF_VOL}
    docker volume create ${NC_PHP7_CONF_VOL}
    docker volume create ${NC_NGINX_CONF_VOL}
    docker container run \
        --name ${CONTENEUR} \
        --tmpfs /run \
        --tmpfs /run/lock \
        --tmpfs /tmp \
        -v /sys/fs/cgroup \
        -v ${NC_DATA_VOL}:${NC_DATA_DIR} \
        -v ${NC_LOG_VOL}:${NC_LOG_DIR} \
        -v ${NC_HTML_VOL}:${NC_HTML_DIR} \
        -v ${NC_CONF_VOL}:${NC_CONF_DIR} \
        -v ${NC_PHP7_CONF_VOL}:${NC_PHP7_CONF_DIR} \
        -v ${NC_NGINX_CONF_VOL}:${NC_NGINX_CONF_DIR} \
        -p ${NC_HTTP_PORT}:80 \
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
    docker container exec ${CONTENEUR} cat /var/log/nginx/error.log ; \
    docker container exec ${CONTENEUR} cat /var/log/nextcloud/nextcloud.log

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
    
    docker container stop ${CONTENEUR}
    docker container rm ${CONTENEUR}
    docker volume rm ${NC_HTML_VOL}
    docker volume rm ${NC_DATA_VOL}
    docker volume rm ${NC_LOG_VOL}
    docker volume rm ${NC_CONF_VOL}
    docker volume rm ${NC_PHP7_CONF_VOL}
    docker volume rm ${NC_NGINX_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker image rm ${IMAGE}

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a
    docker image save -o ${APPLI}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i ${APPLI}.tar
    #docker image tag ${IMAGE}
    rm -v ${APPLI}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a


### Créer le fichier 'docker-compose.yml'

    .  env.sh

    echo "# docker-compose.yml
        version: '3'
              
        services:
              
          nc:
            build:
              context: .
              args:
                BASE: ${BASE}
            image: ${IMAGE}
            ports:
              - ${NC_HTTP_PORT:-8080}:80
            tmpfs:
              - /run
              - /run/lock
              - /tmp
            volumes:
              - /sys/fs/cgroup
              - ${NC_HTML_VOL}:${NC_HTML_DIR}
              - ${NC_LOG_VOL}:${NC_LOG_DIR}
              - ${NC_CONF_VOL}:${NC_CONF_DIR}
              - ${NC_DATA_VOL}:${NC_DATA_DIR}
              - ${NC_PHP7_CONF_VOL}:${NC_PHP7_CONF_DIR}
              - ${NC_NGINX_CONF_VOL}:${NC_NGINX_CONF_DIR}
              
        volumes:
              
          ${NC_HTML_VOL}:
            external: true
          ${NC_LOG_VOL}:
            external: true
          ${NC_CONF_VOL}:
            external: true
          ${NC_DATA_VOL}:
            external: true
          ${NC_PHP7_CONF_VOL}:
            external: true
          ${NC_NGINX_CONF_VOL}:
            external: true
        " | sed -e 's/^        //' | tee docker-compose.yml

### Lancer le service

    docker-compose up -d
    
### Consulter les journaux

    docker-compose logs

###  Aller dans le conteneur

    docker-compose exec nc sh

### Arrêter le service

    docker-compose stop









    maintenance:install \
    [--database DATABASE] \
    [--database-name DATABASE-NAME] \
    [--database-host DATABASE-HOST] \
    [--database-port DATABASE-PORT] \
    [--database-user DATABASE-USER] \
    [--database-pass [DATABASE-PASS]] \
    [--database-table-prefix [DATABASE-TABLE-PREFIX]] \
    [--database-table-space [DATABASE-TABLE-SPACE]] \
    [--admin-user ADMIN-USER] \
    [--admin-pass ADMIN-PASS] \
    [--admin-email [ADMIN-EMAIL]] \
    [--data-dir DATA-DIR]

    occ  maintenance:install --database "sqlite" --database-name "nextcloud"  --database-user "root" --database-pass
    "password" --admin-user "admin" --admin-pass "password" 
