#  Raspberry Pi / Docker

## Nginx basé sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        #APPLI=$(basename $(pwd)) # nginx
        APPLI=nginx
        BASE=${MAINTENER}/alpine
        
        NGINX_HTTP_PORT=80
        #NGINX_HTTPS_PORT=443
        #NGINX_CONF_DIR=/etc/nginx
        #NGINX_CERT_DIR=/etc/letsencrypt
        #NGINX_DATA_DIR=/var/lib/nginx
        NGINX_HTML_DIR=/var/lib/nginx/html
        #NGINX_CONF_VOL=${APPLI}${NGINX_CONF_DIR//\//-}
        #NGINX_CERT_VOL=${APPLI}${NGINX_CERT_DIR//\//-}
        #NGINX_DATA_VOL=${APPLI}${NGINX_DATA_DIR//\//-}
        NGINX_HTML_VOL=${APPLI}${NGINX_HTML_DIR//\//-}
        
        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${MAINTENER}_${APPLI}
        COMMANDE=""
        ' | sed -e 's/^        //' | tee env.sh
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'http.conf'

    echo "# http.conf
        server {
            listen 80 default_server;
            listen [::]:80 default_server;
            root ${NGINX_HTML_DIR};
            location / {
            }
        }
        " | sed -e 's/^        //' | tee http.conf

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ENV NGINX_HTML_DIR=/var/lib/nginx/html \\
            NGINX_HTTP_PORT=80 \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            # Installation de nginx
            apk --no-cache add nginx ; \\
            rc-update add nginx default ; \\
            mv -v /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.origin ; \\
            echo "# default.conf" > /etc/nginx/conf.d/default.conf ; \\
            echo "server {" >> /etc/nginx/conf.d/default.conf ; \\
            echo "  listen 80 default_server;" >> /etc/nginx/conf.d/default.conf ; \\
            echo "  listen [::]:80 default_server;" >> /etc/nginx/conf.d/default.conf ; \\
            echo "  root ${NGINX_HTML_DIR};" >> /etc/nginx/conf.d/default.conf ; \\
            echo "  location / {" >> /etc/nginx/conf.d/default.conf ; \\
            echo "  }" >> /etc/nginx/conf.d/default.conf ; \\
            echo "}" >> /etc/nginx/conf.d/default.conf ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        EXPOSE ${NGINX_HTTP_PORT}
        VOLUME /sys/fs/cgroup ${NGINX_HTML_DIR}
        
        ' | sed -e 's/^        //' | tee Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Créer les volumes

    docker volume create ${NGINX_HTML_VOL}

### Lancer le conteneur

    .  env.sh

    docker container run \
        --name ${CONTENEUR} \
        -v ${NGINX_HTML_VOL}:${NGINX_HTML_DIR} \
        -p ${NGINX_HTTP_PORT}:80 \
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

    #// aller dans le conteneur en tant que USER ('root' par défaut)
    docker container exec -it ${CONTENEUR} sh

    #// demarrer le conteneur
    docker container start ${CONTENEUR}

    #// arreter le conteneur
    docker container stop ${CONTENEUR}

    #// redemarrer le conteneur
    docker container restart ${CONTENEUR}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR}
    # ATTTENTION
    docker volume rm ${NGINX_HTML_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker image rm ${IMAGE}

### Nettoyer tout
  
    .  env.sh

    # ATTENTION !
    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR} ; docker volume rm  docker volume rm ${NGINX_HTML_VOL} ; docker image rm ${IMAGE}

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a 
    docker image save -o /tmp/${APPLI}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i /tmp/${APPLI}.tar
    # docker image tag ${IMAGE}:<TAG>
    sudo rm -fv /tmp/${APPLI}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;\
        for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; \
    done

    docker image ls -a


### Créer le fichier 'docker-compose.yml'

    .  env.sh

    echo "# docker-compose.yml
        version: '3'
              
        services:
              
          web:
            build:
              context: .
              args:
                BASE: ${BASE}
            image: ${IMAGE}
            ports:
              - ${NGINX_HTTP_PORT:-80}:80
            tmpfs:
              - /run
              - /run/lock
              - /tmp
            volumes:
              - /sys/fs/cgroup
              - ${NGINX_HTML_VOL:-${APPLI}-var-lib-nginx-html}:/var/lib/nginx/html
              
        volumes:
              
          ${NGINX_HTML_VOL:-${APPLI}-var-lib-nginx-html}:
            #external: true
        " | sed -e 's/^        //' | tee docker-compose.yml
