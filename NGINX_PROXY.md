#  Raspberry Pi / Docker

## Nginx-proxy basé sur Alpine

### Lectures

### Lectures

* [Docker](https://github.com/jwilder/nginx-proxy)
* [...](https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/)
* [...](https://www.freecodecamp.org/news/docker-compose-nginx-and-letsencrypt-setting-up-website-to-do-all-the-things-for-that-https-7cb0bf774b7e/)
* [...](https://hub.docker.com/r/linuxserver/letsencrypt/)
* [LetsEncrypt](https://hub.docker.com/r/linuxserver/letsencrypt/)
* [Proxy](https://openclassrooms.com/fr/courses/1733551-gerez-votre-serveur-linux-et-ses-services/5236081-mettez-en-place-un-reverse-proxy-avec-nginx)
*

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        BASE=${MAINTENER}/alpine
        #APPLI=$(basename $(pwd)) # nginx-proxy
        APPLI=proxy
        PORT=40000
        
        WEB_APPLI=nextcloud
        NC_HTTP_PORT=80
        # Nginx
        NC_PHP7_CONF_DIR=/etc/php7
        NC_HTML_CONF_DIR=/etc/nginx
        NC_HTML_ROOT_DIR=/var/lib/nginx/html
        NC_HTML_LOG_DIR=/var/log/nginx
        # Nextcloud
        NC_CONF_DIR=/etc/nextcloud
        NC_LOG_DIR=/var/log/nextcloud
        NC_DATA_DIR=/var/lib/nextcloud/data
                
        NC_PHP7_CONF_VOL=${APPLI}-html${NC_PHP7_CONF_DIR//\//-}
        NC_HTML_ROOT_VOL=${APPLI}-html${NC_HTML_ROOT_DIR//\//-}
        NC_HTML_LOG_VOL=${APPLI}-html${NC_HTML_LOG_DIR//\//-}
        NC_CONF_VOL=${APPLI}${NC_CONF_DIR//\//-}
        NC_LOG_VOL=${APPLI}${NC_LOG_DIR//\//-}
        NC_DATA_VOL=${APPLI}${NC_DATA_DIR//\//-}

        LAB_APPLI=jupyterlab
        JUPYTER_PORT=9898
        JUPYTER_USER=jovyan
        JUPYTER_WORK_DIR=/home/${JUPYTER_USER}/work
        JUPYTER_WORK_VOL=${APPLI}${JUPYTER_WORK_DIR//\//-}
        JUPYTER_BIN_DIR=/home/${JUPYTER_USER}/bin
        JUPYTER_BIN_VOL=${APPLI}${JUPYTER_BIN_DIR//\//-}

        PROXY_HTTP_PORT=$((80+$PORT))
        PROXY_HTTPS_PORT=$((443+$PORT))
        PROXY_CONF_DIR=/etc/nginx
        PROXY_LOG_DIR=/var/log/nginx
        PROXY_CERT_DIR=/etc/letsencrypt
        PROXY_HTML_ROOT_DIR=/var/lib/nginx/html
        PROXY_HTML_LOG_DIR=/var/log/nginx

        PROXY_CONF_VOL=${APPLI}${PROXY_CONF_DIR//\//-}
        PROXY_LOG_VOL=${APPLI}${PROXY_LOG_DIR//\//-}
        PROXY_CERT_VOL=${APPLI}${PROXY_CERT_DIR//\//-}
        
        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${MAINTENER}_${APPLI}
        COMMANDE=""
        DOMAINE=lhb97.eu
        CONTACT=philippe
        echo BASE=${BASE}
        echo APPLI=${APPLI}
        set|grep "^PROXY_"
        ' | sed -e 's/^        //' | tee env.sh
        
    chmod +x env.sh
    . env.sh

### Créer le fichier '${DOMAINE}.conf'  avec nextcloud et jupyter et les modifications Certbot

    echo "# ${DOMAINE}.conf
        upstream ${DOMAINE//./_}_nc {
            server nc:80;
        }
        upstream ${DOMAINE//./_}_jupyter {
            server lab:8888;
        }
        server {
          if (\$host = ${DOMAINE}) {
            return 301 https://\$host\$request_uri;
          } # managed by Certbot
          if (\$host = www.${DOMAINE}) {
            return 301 https://\$host\$request_uri;
          } # managed by Certbot
          listen 80;
          listen [::]:80;
          server_name ${DOMAINE} www.${DOMAINE};
            return 404; # managed by Certbot
        }
        server {
            server_name ${DOMAINE} www.${DOMAINE};
            access_log /var/log/nginx/${DOMAINE}.access.log;
            error_log /var/log/nginx/${DOMAINE}.error.log;
            location /jupyter {
                include proxy_params;
                proxy_http_version 1.1;
                proxy_pass http://${DOMAINE//./_}_jupyter;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection \"upgrade\";
            }
            location / {
                include proxy_params;
                proxy_http_version 1.1;
                proxy_set_header Connection \"\";
                proxy_pass http://${DOMAINE//./_}_nc;
            }
            client_max_body_size        10G;
            client_body_buffer_size     400M;
            listen [::]:443 ssl ipv6only=on; # managed by Certbot
            listen 443 ssl; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/${DOMAINE}/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/${DOMAINE}/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
        }
        " | sed -e 's/^        //' | tee ${DOMAINE}.conf

### Créer le fichier '${DOMAINE}.conf'  avec nextcloud et jupyter mais SANS les modifications Certbot

    echo "# ${DOMAINE}.conf
        upstream ${DOMAINE//./_}_nc {
            server nc:80;
        }
        upstream ${DOMAINE//./_}_jupyter {
            server lab:8888;
        }
        server {
            server_name ${DOMAINE} www.${DOMAINE};
            access_log /var/log/nginx/${DOMAINE}.access.log;
            error_log /var/log/nginx/${DOMAINE}.error.log;
            location /jupyter {
                include proxy_params;
                proxy_http_version 1.1;
                proxy_pass http://${DOMAINE//./_}_jupyter;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection \"upgrade\";
            }
            location / {
                include proxy_params;
                proxy_http_version 1.1;
                proxy_set_header Connection \"\";
                proxy_pass http://${DOMAINE//./_}_nc;
            }
            client_max_body_size        10G;
            client_body_buffer_size     400M;
        }
        " | sed -e 's/^        //' | tee ${DOMAINE}_sans.conf.exemple


### Créer le fichier 'proxy_params'

    echo "# ${PROXY_CONF_DIR}/proxy_params
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        " | sed -e 's/^        //' | tee proxy_params


### Créer le service 'firstrun'

    echo $'#!/sbin/openrc-run
        description="First run script"
        depend()
        {
          need net
          use nginx
        }
        start()
        {
          rc-update del firstrun default
          ebegin "Executing firstrun"...
          rc=0
          if [ -x /root/firstrun.sh ]; then /root/firstrun.sh;fi
          eend $rc " terminée."
        }
        ' | sed -e 's/^        //' | tee firstrun
        
    chmod +x firstrun
        
### Créer le fichier 'firstrun.sh'

    echo $'#!/bin/sh
        echo Usage: /etc/nginx/conf.d/service.conf.sh domain[,domain] email [port [host]]
        set -ex
        mv -v $0 $0.$(date -Iseconds|sed -e \'s|[-:]||g\' -e \'s|[+]\d\+||\')
        exit 0
        ' | sed -e 's/^        //' | tee firstrun.sh
        
    chmod +x firstrun.sh

### Créer le fichier 'firstrun.sh' de base

    echo $'#!/bin/sh
        #!/sbin/openrc-run
        description="First run script"
        depend()
        {
          need net
          use nginx
        }
        start()
        {
          rc-update del firstrun default
          ebegin "Executing firstrun"...
          rc=0
          if [ -x /root/firstrun.sh ]; then /root/firstrun.sh;fi
          eend $rc " terminée."
        }
        exit 0
        ' | sed -e 's/^        //' | tee firstrun.sh.exemple


### Créer le fichier 'service.conf.in'

    echo "# ${PROXY_CONF_DIR}/conf.d/service.conf.in
        upstream <BACKEND> {
            server <SERVICE_HOST>:<SERVICE_PORT>;
        }

        server {
            listen 80;
            listen [::]:80;
            server_name <DOMAINE>, www.<DOMAINE>;
            access_log /var/log/nginx/<DOMAINE>.access.log;
            error_log /var/log/nginx/<DOMAINE>.error.log;
            client_max_body_size 10G;
            client_body_buffer_size 400M;
            location / {
                include proxy_params;
                proxy_http_version 1.1;
                proxy_set_header Connection \"\";
                proxy_pass http://<BACKEND>;
            }
        }
        " | sed -e 's/^        //' | tee service.conf.in


### Créer le fichier 'service.conf.sh'

    echo $'#!/bin/sh
        # ${PROXY_CONF_DIR}/service.conf.sh
        #
        # Usage: ${PROXY_CONF_DIR}/conf.d/service.conf.sh domaine[,domaine] mail [port [host]]
        #
        way=$(ip route list|grep default|cut -d " " -f 3)
        domain="$1"
        email="$2"
        port=$(echo $3|sed -e "s|^$|80|g")
        host=$(echo $4|sed -e "s|^$|$way|g")
        for name in $(echo $1|sed -e "s|,| |g")
        do
          bck=$(echo $name|sed -e "s|[.]|_|g")_backend
          sed -e "s|<BACKEND>|$bck|g" -e "s|<DOMAINE>|$name|g" -e "s|<SERVICE_PORT>|$port|g" -e "s|<SERVICE_HOST>|$host|g" /etc/nginx/conf.d/service.conf.in > /etc/nginx/conf.d/$name.conf
        done
        certbot run --non-interactive --redirect --preferred-challenges http-01 --nginx --agree-tos \\
            --domain $domain --email $email
        nginx -t
        nginx -s reload
    ' | sed -e 's/^        //' | tee service.conf.sh
    
    chmod +x service.conf.sh


### Créer le fichier 'letsencrypt_renew'

    echo $'#!/bin/sh
        # /etc/periodic/monthly/letsencrypt_renew
        certbot renew --non-interactive 
        nginx -s reload
        ' | sed -e 's/^        //' | tee letsencrypt_renew
        
    chmod +x letsencrypt_renew

### Créer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG PROXY_CONF_DIR
        ARG PROXY_LOG_DIR
        ARG PROXY_CERT_DIR
        ARG PROXY_HTTP_PORT
        ARG PROXY_HTTPS_PORT


        ENV PROXY_CONF_DIR=${PROXY_CONF_DIR:-/etc/nginx} \\
            PROXY_LOG_DIR=${PROXY_LOG_DIR:-/var/log/nginx} \\
            PROXY_CERT_DIR=${PROXY_CERT_DIR:-/etc/letsencrypt} \\
            PROXY_HTTP_PORT=${PROXY_HTTP_PORT:-80} \\
            PROXY_HTTPS_PORT=${PROXY_HTTPS_PORT:-443} \\
            LANG=C.UTF-8

        #
        # Installation des paquets
        #
        RUN set -ex ; \\
            # Installation de nginx
            apk --no-cache upgrade ; \\
            apk --no-cache add nginx certbot certbot-nginx ; \\
            # Activation du service nginx
            rc-update add nginx default ; \\
            # Sauvegarde de la configuration par defaut
            mv -v ${PROXY_CONF_DIR}/conf.d/default.conf ${PROXY_CONF_DIR}/conf.d/default.conf.origin ; \\
            echo paquets installés
        #
        # Installation du fichier proxy_params
        #
        COPY ./proxy_params /root/ 
        RUN set -ex ; \\
            mv -v /root/proxy_params ${PROXY_CONF_DIR} ; \\ 
            cat ${PROXY_CONF_DIR}/proxy_params ; \\
            echo fichier proxy_params installé
        #
        # Installation des fichiers de configuration
        #
        COPY ./*.conf /root/
        COPY ./service.conf.* /root/
        RUN set -ex ; \\
            mv -v /root/*.conf ${PROXY_CONF_DIR}/conf.d/ ; \\
            cat ${PROXY_CONF_DIR}/conf.d/*.conf ; \\
            mv -v /root/service.conf.* ${PROXY_CONF_DIR}/conf.d/ ; \\
            chmod +x ${PROXY_CONF_DIR}/conf.d/service.conf.sh ; \\
            cat ${PROXY_CONF_DIR}/conf.d/service.conf.in ; \\
            cat ${PROXY_CONF_DIR}/conf.d/service.conf.sh ; \\
            echo fichiers de configuration installés
        #
        # Installation du service firstrun
        #
        COPY ./firstrun /etc/init.d/
        RUN set -ex ; \\
            chmod +x  /etc/init.d/firstrun ; \\
            cat /etc/init.d/firstrun ; \\
        #
        # Activation du service firstrun
        #
            rc-update add firstrun default ; \\
            echo fichier firstrun installé et activé
            
        #
        # Installation du scripte de renouvellement des certificats
        #
        COPY ./letsencrypt_renew /etc/periodic/monthly/
        RUN set -ex ; \\
            chmod +x /etc/periodic/monthly/letsencrypt_renew ; \\
            cat /etc/periodic/monthly/letsencrypt_renew ; \\
            echo scripte de renouvellement des certificats installé
        
        #
        # Installation du scripte de premier démarrage
        #
        COPY firstrun.sh /root/
        RUN set -ex ; \\
            chmod +x /root/firstrun.sh ; \\
            cat /root/firstrun.sh ; \\
            echo scripte de premier démarrage installé
        
        ENTRYPOINT ["/sbin/openrc-init"]
        EXPOSE 80 443
        VOLUME /sys/fs/cgroup ${PROXY_CONF_DIR} ${PROXY_CERT_DIR} ${PROXY_LOG_DIR}
        
        ' | sed -e 's/^        //' | tee Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Créer les volumes

    docker volume create ${PROXY_LOG_VOL}
    docker volume inspect ${PROXY_LOG_VOL}|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    docker volume create ${PROXY_CONF_VOL}
    docker volume inspect ${PROXY_CONF_VOL}|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    docker volume create ${PROXY_CERT_VOL}
    docker volume inspect ${PROXY_CERT_VOL}|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2

### Lancer le conteneur

    .  env.sh

    docker container run \
        --name ${CONTENEUR} \
        -v ${PROXY_LOG_VOL}:${PROXY_LOG_DIR} \
        -v ${PROXY_CONF_VOL}:${PROXY_CONF_DIR} \
        -v ${PROXY_CERT_VOL}:${PROXY_CERT_DIR} \
        -p $((PROXY_HTTP_PORT+100)):80 \
        -p $((PROXY_HTTPS_PORT+100)):443 \
        -d ${IMAGE} ${COMMANDE}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps

    #// Consulter les ports qui ecoutent
    docker container exec ${CONTENEUR} netstat -l

    #// Consulter les journaux
    docker container exec ${CONTENEUR} cat /var/log/nginx/error.log

    #// Créer un service
    docker container exec ${CONTENEUR} /etc/nginx/conf.d/service.conf.sh <domaine>,www.<domaine> <contact>@<domaine>

    #// aller dans le conteneur en tant que USER ('root' par défaut)
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
    docker container rm ${CONTENEUR}
    # ATTTENTION
    docker volume rm ${PROXY_LOG_VOL} ${PROXY_CONF_VOL} ${PROXY_CERT_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker image rm ${IMAGE}

### Nettoyer tout
  
    .  env.sh

    # ATTENTION !
    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR} ; docker volume rm ${PROXY_CONF_VOL} ${PROXY_CERT_VOL} ; docker image rm ${IMAGE}

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a
    docker image save -o ${APPLI}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i ${APPLI}.tar
    # docker image tag ${IMAGE}:<TAG>
    rm -fv ${APPLI}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;\
        for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; \
    done

    docker image ls -a


## Docker-Compose

### Lectures

* [systemd](https://gist.github.com/mosquito/b23e1c1e5723a7fd9e6568e5cf91180f)
* [...](https://doc.ubuntu-fr.org/creer_un_service_avec_systemd)
* [...](https://github.com/nextcloud/server/issues/13713)
* 

### Créer le fichier 'docker-compose.yml'

    .  env.sh

    echo "# docker-compose.yml
        version: '3'
        
        services:
        
            nc:
              build:
                context: ../${WEB_APPLI}
                args:
                  BASE: ${BASE}
              image: ${MAINTENER}/${WEB_APPLI}
              ports:
                - ${NC_HTTP_PORT:-8080}:80
              networks:
                - proxy-back-network
              tmpfs:
                - /run
                - /run/lock
                - /tmp
              volumes:
                - /sys/fs/cgroup
                - ${NC_HTML_ROOT_VOL}:${NC_HTML_ROOT_DIR}
                - ${NC_HTML_LOG_VOL}:${NC_HTML_LOG_DIR}
                - ${NC_PHP7_CONF_VOL}:${NC_PHP7_CONF_DIR}
                - ${NC_CONF_VOL}:${NC_CONF_DIR}
                - ${NC_LOG_VOL}:${NC_LOG_DIR}
                - ${NC_DATA_VOL}:${NC_DATA_DIR}


            lab:
              build:
                context: ../${LAB_APPLI}
                args:
                  BASE: ${BASE}
              image: ${MAINTENER}/${LAB_APPLI}
              ports:
                - ${JUPYTER_PORT:-9898}:8888
              networks:
                - proxy-back-network
              tmpfs:
                - /run
                - /run/lock
                - /tmp
              volumes:
                - /sys/fs/cgroup
                - ${JUPYTER_WORK_VOL}:${JUPYTER_WORK_DIR}
                - ${JUPYTER_BIN_VOL}:${JUPYTER_BIN_DIR}


            proxy:
              build:
                context: .
                args:
                  BASE: ${BASE}
              image: ${IMAGE}
              ports:
                - ${PROXY_HTTP_PORT}:80
                - ${PROXY_HTTPS_PORT}:443
              networks:
                - proxy-front-network
                - proxy-back-network
              tmpfs:
                - /run
                - /run/lock
                - /tmp
              volumes:
                - /sys/fs/cgroup
                - ${PROXY_CONF_VOL}:${PROXY_CONF_DIR} 
                - ${PROXY_LOG_VOL}:${PROXY_LOG_DIR}
                - ${PROXY_CERT_VOL}:${PROXY_CERT_DIR}
         
        networks:
            proxy-front-network:
              driver: bridge
            proxy-back-network:
              driver: bridge
        volumes:
          
            ${NC_HTML_ROOT_VOL}:
              external: true
            ${NC_HTML_LOG_VOL}:
              external: true
            ${NC_PHP7_CONF_VOL}:
              external: true
            ${NC_LOG_VOL}:
              external: true
            ${NC_CONF_VOL}:
              external: true
            ${NC_DATA_VOL}:
              external: true
        
            ${JUPYTER_WORK_VOL}:
              external: true
            ${JUPYTER_BIN_VOL}:
              external: true
      
            ${PROXY_CONF_VOL}:
              external: true
            ${PROXY_CERT_VOL}:
              external: true
            ${PROXY_LOG_VOL}:
              external: true
        " | sed -e 's/^        //' | tee docker-compose.yml

### Créer les volumes

    docker volume create ${NC_HTML_ROOT_VOL}
    docker volume create ${NC_HTML_LOG_VOL}
    docker volume create ${NC_PHP7_CONF_VOL}
    docker volume create ${NC_LOG_VOL}
    docker volume create ${NC_CONF_VOL}
    docker volume create ${NC_DATA_VOL}
    docker volume create ${JUPYTER_WORK_VOL}
    docker volume create ${JUPYTER_BIN_VOL}
    docker volume create ${PROXY_LOG_VOL}
    docker volume create ${PROXY_CONF_VOL}
    docker volume create ${PROXY_CERT_VOL}
    for vol in ${NC_HTML_ROOT_VOL} ${NC_HTML_LOG_VOL} ${NC_PHP7_CONF_VOL} ${NC_LOG_VOL} ${NC_CONF_VOL} ${NC_DATA_VOL}  ${JUPYTER_WORK_VOL} ${JUPYTER_BIN_VOL} ${PROXY_LOG_VOL} ${PROXY_CONF_VOL} ${PROXY_CERT_VOL} 
    do
      docker volume create $vol
      docker volume inspect $vol|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    done
    docker volume ls -f name="${APPLI}*"

### Lancer les services

    docker-compose up -d
    
### Consulter les journaux

    docker-compose logs

###  Créer les certificats

    docker-compose exec proxy /etc/nginx/conf.d/service.conf.sh ${DOMAINE},www.${DOMAINE} ${CONTACT}@${DOMAINE} 80 web

###  Consulter les certificats

    docker-compose exec proxy certbot certificates

###  Aller dans le conteneur

    docker-compose exec proxy sh

### Arrêter les services

    docker-compose stop

### Démarrer les services

    docker-compose start

### Redémarrer les services

    docker-compose restart

### Lister les services

    docker-compose ps --services

### Lister les conteneurs

    docker-compose ps

### Arrêter et supprimer les services

    docker-compose down

### Créer le fichier 'docker-compose@.service'

    #// si nécessaire créer l'utilisateur 'docker'
    UID=$(cat /etc/group|grep docker|cut -d ':' -f 3)
    adduser --system --no-create-home --uid ${UID} --gid ${UID} --disabled-password --disabled-login docker

    echo $'# docker-compose@.service
        [Unit]
        Description=%i service with docker compose
        Requires=docker.service
        After=docker.service

        [Service]
        Type=simple
        User=docker
        Group=docker
        UMask=007
        Restart=always

        WorkingDirectory=/etc/docker/compose/%i

        # Remove old containers, images and volumes
        ExecStartPre=/usr/local/bin/docker-compose down
        # ExecStartPre=/usr/local/bin/docker-compose down -v
        # ExecStartPre=/usr/local/bin/docker-compose rm -fv
        # ExecStartPre=-/bin/bash -c \'docker volume ls -qf "name=^%i_" | xargs docker volume rm\'
        # ExecStartPre=-/bin/bash -c \'docker network ls -qf "name=^%i_" | xargs docker network rm\'
        # ExecStartPre=-/bin/bash -c \'docker container ls -aqf "name=^%i_*" | xargs docker rm\'

        # Compose up
        ExecStart=/usr/local/bin/docker-compose up

        # Compose down, remove containers and volumes
        #ExecStop=/usr/local/bin/docker-compose down -v
        ExecStop=/usr/local/bin/docker-compose down

        [Install]
        WantedBy=multi-user.target
        ' | sed -e 's/^        //' | tee docker-compose@.service
        
    
### Copier le fichier 'docker-compose@.service'

    sudo cp -v docker-compose@.service /etc/systemd/system/

### Copier le fichier 'docker-compose.yml' et les fichiers 'Dockerfile'

    sudo mkdir -p /etc/docker/compose/proxy /etc/docker/compose/nextcloud /etc/docker/compose/jupyterlab
    sudo cp -v docker-compose.yml Dockerfile /etc/docker/compose/proxy
    sudo cp -v ../nextcloud/Dockerfile /etc/docker/compose/nextcloud
    sudo cp -v ../jupyterlab/Dockerfile /etc/docker/compose/jupyterlab
    sudo chown -Rv root:docker /etc/docker/compose
    sudo chmod -Rv g+w /etc/docker/compose/proxy /etc/docker/compose/nextcloud /etc/docker/compose/jupyterlab

### Créer les volumes

    Lors du premier démarrage mettre le paramètre 'external=false' pour l'ensemble des volumes, puis arrêter le service 'proxy' pour remettre le paramettre 'external=true' pour l'ensemble des volumes, puis créer les volumes : 

    # en tant que 'root' dans le répertoire '/etc/docker/compose/proxy'
    # dans le fichier 'docker-compose.yml' mettre 'external=false' pour initialiser les volumes 
    sudo -u docker docker-compose up -d
    # attendre...
    sudo -u docker docker-compose down
    # dans le fichier 'docker-compose.yml' remettre 'external=true' 
    # puis "créer" les volumes pour les conserver

    sudo -u docker docker volume create --name=proxy-html-var-lib-nginx-html
    sudo -u docker docker volume create --name=proxy-html-var-log-nginx
    sudo -u docker docker volume create --name=proxy-etc-nginx
    sudo -u docker docker volume create --name=proxy-etc-letsencrypt
    sudo -u docker docker volume create --name=proxy-var-log-nginx
    
    # lister les volumes créés
    docker volume ls -f name="proxy*"
    for vol in $(docker volume ls -qf name="proxy-*")
    do
      echo -n "$vol -> "
      docker volume inspect $vol|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    done

### Activer le service 'proxy'

    sudo systemctl enable docker-compose@proxy

### Désactiver le service 'proxy'

    sudo systemctl disable docker-compose@proxy

### Démarrer le service 'proxy'

    sudo systemctl start docker-compose@proxy
    
    #!! consulter le journal...
    systemctl status docker-compose@proxy
    journalctl -f -u docker-compose@proxy --since today

### Arrêter le service 'proxy'

    sudo systemctl stop docker-compose@proxy

### Redémarrer le service 'proxy'

    sudo systemctl restart docker-compose@proxy

### Vérifier le service 'proxy'

    systemctl status docker-compose@proxy
    systemctl is-active docker-compose@proxy
    systemctl is-failed docker-compose@proxy
    netstat -lt








### docker-gen

        go get github.com/robfig/glock
        cd /root/go/src/github.com/robfig/glock/
        go build ../*
        alias glock="$(pwd)/glock"
        
        go get github.com/BurntSushi/toml        
        go get github.com/jwilder/docker-gen
        cd /root/go/src/github.com/jwilder/docker-gen
        
        make
        
