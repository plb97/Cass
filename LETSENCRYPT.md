#  Raspberry Pi / Docker

## LetsEncrypt

### Lectures

* [LetsEncrypt](https://hub.docker.com/r/linuxserver/letsencrypt/)
* [...](https://github.com/linuxserver/docker-letsencrypt/)
* [...](https://openclassrooms.com/fr/courses/1733551-gerez-votre-serveur-linux-et-ses-services/5236056-securisez-votre-serveur-web/)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        CONTENEUR=letsencrypt
        IMAGE=linuxserver/letsencrypt:arm32v7-latest
        
        PUID=1000
        PGID=1000
        TZ=Europe/Paris
        URL=lhb97.eu
        #DNSPLUGIN=cloudflare #optional
        #DUCKDNSTOKEN=token #optional
        EMAIL=philippe@lhb97.eu
        DHLEVEL=2048 #optional
        ONLY_SUBDOMAINS=false
        #EXTRA_DOMAINS=extradomains #optional
        STAGING=true #optional
        
        #CONFIG=/etc/nginx/sites-enabled
        CONFIG=$(pwd)/config
        
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### docker create

    .  env.sh
    
    docker create \
      --name=${CONTENEUR} \
      --cap-add=NET_ADMIN \
      -e PUID=${PUID} \
      -e PGID=${PGID} \
      -e TZ=${TZ} \
      -e URL=${URL} \
      -e SUBDOMAINS=www, \
      -e VALIDATION=http \
      -e EMAIL=${EMAIL} \
      -e DHLEVEL=2048 \
      -e ONLY_SUBDOMAINS=${ONLY_SUBDOMAINS} \
      -e STAGING=${STAGING} \
      -p 443:443 \
      -p 80:80\
      -v ${CONFIG}:/config \
      --restart unless-stopped \
      ${IMAGE}
      

### Lancer le conteneur

    .  env.sh
    
    docker container run --privileged \
        --name=${CONTENEUR} \
        --cap-add=NET_ADMIN \
        -e PUID=${PUID} \
        -e PGID=${PGID} \
        -e TZ=${TZ} \
        -e URL=${URL} \
        -e SUBDOMAINS=www, \
        -e VALIDATION=http \
        -e EMAIL=${EMAIL} \
        -e DHLEVEL=2048 \
        -e ONLY_SUBDOMAINS=${ONLY_SUBDOMAINS} \
        -e STAGING=${STAGING} \
        -p 443:443 \
        -p 80:80\
        -v ${CONFIG}:/config \
        --restart unless-stopped \
        -d ${IMAGE}

### Utiliser le conteneur

    .  env.sh
    
    #// demarrer le conteneur
    docker container start ${CONTENEUR}

    #// arreter le conteneur
    docker container stop ${CONTENEUR}

    #// redemarrer le conteneur
    docker container restart ${CONTENEUR}

    #// aller dans le conteneur en tant que USER ('root' par défaut)
    docker container exec -it ${CONTENEUR} sh

    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps

    #// Consulter les ports qui ecoutent
    docker container exec ${CONTENEUR} netstat -l

    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps
    

### Creer le fichier 'docker-compose.yml'

    echo "version: '2'
        services:
          ${CONTENEUR}:
          image: ${IMAGE}
            container_name: ${CONTENEUR}
            cap_add:
              - NET_ADMIN
            environment:
              - PUID=${PUID}
              - PGID=${PGID}
              - TZ=${TZ}
              - URL=${URL}
              - SUBDOMAINS=www,
              - VALIDATION=http
              - EMAIL=${EMAIL}
              - DHLEVEL=2048
              - ONLY_SUBDOMAINS=${ONLY_SUBDOMAINS}
              - STAGING=${STAGING}
            volumes:
              - ${CONFIG}:/config
            ports:
              - 443:443
              - 80:80
            restart: unless-stopped
            " | sed -e 's/^        //' | tee docker-compose.yml


        docker-compose up -d


## Certbot

### Tests

    certbot certonly --config-dir $(pwd)/certbot --work-dir $(pwd)/certbot --logs-dir $(pwd)/certbot \
       --staging --standalone --agree-tos --preferred-challenges http-01 \
        --email philippe@lhb97.eu -d lhb97.eu -d www.lhb97.eu

    certbot certificates --config-dir $(pwd)/certbot --work-dir $(pwd)/certbot --logs-dir $(pwd)/certbot

### Obtenir et installer un certificat pour Nginx

    sudo certbot run --preferred-challenges http-01 --nginx --agree-tos --domains lhb97.eu,www.lhb97.eu \
    --email philippe@lhb97.eu

### Modifier un certificat
    certbot certonly --cert-name lhb97.eu -d lhb97.eu,www.lhb97.eu
    
### Renouveler un certificat

    sudo certbot renew --preferred-challenges http-01 \
    --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"

