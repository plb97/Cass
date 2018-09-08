#  Cass

## Installation de 'Nextcloud' dans un conteneur 'Docker'

### Lectures


## Installation de Nextcloud dans un conteneur Docker avec 'mount'

### Lectures

* [nextcloud](https://hub.docker.com/r/arm32v7/nextcloud/)
* [volume](https://docs.docker.com/storage/volumes/#start-a-container-with-a-volume)
* [bind](https://docs.docker.com/storage/bind-mounts/#start-a-container-with-a-bind-mount)
* [administration](https://docs.nextcloud.com/server/13/admin_manual/configuration_server/occ_command.html)
* [SSL](https://doc.ubuntu-fr.org/tutoriel/comment_creer_un_certificat_ssl)
* [SSL](https://www.quennec.fr/trucs-astuces/systèmes/gnulinux/commandes/openssl/openssl-générer-un-certificat-auto-signé)
*


    #// passer 'docker'
    sudo -u docker -i
        
        # creer la volume 'nextcloud-vol'
        NAME=nextcloud
        docker volume create ${NAME}-vol
        docker volume ls
        docker volume inspect ${NAME}-vol
        docker container run -d \
        -it \
        --name ${NAME} \
        --mount source=${NAME}-vol,target=/var/www \
        --privileged \
        -p 1080:80 \
        -p 1443:443 \
        arm32v7/${NAME}

        NAME=nextcloud
        NEXTCLOUD_DATA_DIR=/var/www/data
        docker volume create ${NAME}-data
        docker volume inspect ${NAME}-data
        docker volume ls
        POSTGRES_PASSWORD=... #// a definir
        docker container run -d \
        -it \
        --name ${NAME}_psql \
        --mount source=${NAME}-data,target=${NEXTCLOUD_DATA_DIR} \
        --privileged \
        --link postgres:postgres \
        -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        -p 2080:80 \
        -p 2443:443 \
        arm32v7/${NAME}

    ##// creer le repertoire nextcloud/www
    #    mkdir -pv nextcloud/www
    #    docker container run -d \
    #    -it \
    #    --name nextcloud \
    #    --mount type=bind,source="$(pwd)"/nextcloud/www,target=/var/www \
    #    -p 1080:80 -p 1443:443 arm32v7/nextcloud

    
        # administrer 'Nextcloud'
        docker container exec -it --user www-data nextcloud /bin/bash
            #// ajouter des serveurs de confiance (a adapter)
            HOST=10.0.1.120:1443 #// a adapter
            echo '<?php
            $CONFIG = array (
                "trusted_domains" =>
                    array (
                    "localhost",
                    "${HOST}",
                    ),
            );' > config/system.config.php
        
            #// finir d'installer nextcloud
            php occ  maintenance:install --database "postgres" --database-name "nextcloud"  --database-user "nextcloud" --database-pass "nextcloud" --admin-user "pi" --admin-pass "raspbian"
            #// creer un administrateur
            COMPTE=pi
            UCOMPTE=$(echo ${COMPTE}|awk '{ print toupper(substr($1,1,1)) substr($1,2); }')
            php occ user:add --display-name="${UCOMPTE}" --group="users" --group="db-admins" ${COMPTE}
            #// creer des utilisateurs
            LISTE="" #// a definir (faultatif)
            for COMPTE in ${LISTE}; do UCOMPTE=$(echo ${COMPTE}|awk '{ print toupper(substr($1,1,1)) substr($1,2); }'); echo ${UCOMPTE}; php occ user:add --display-name="${UCOMPTE}" --group="users" ${COMPTE}; done
            #// verifier
            php occ user:list
            
            
            
            php occ config:system:set logtimezone --value="Europe/Paris"
            
            apt-get install -y apt-utils ssl-cert sudo libxml2-utils
            #// ajouter le compte 'www-data' au groupe 'sudo'
            usermod -aG sudo www-data
            #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
            sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
            #// verifier
            cat /etc/sudoers|grep ^%sudo
            #// mettre en place 'SSL'
            a2enmod ssl
            a2ensite default-ssl
            service apache2 reload
            
            
            
            
            #// afficher l'aide
            php occ -h
            #// afficher la version
            php occ -V
            #// afficher le statut
            php occ status
            #// afficher l'aide detaillee sur la commande 'maintenance:mode'
            php occ help maintenance:mode
            #// afficher le statut au format 'json'
            php occ status --output=json
            php occ status --output=json_pretty
            ##// ajouter l'autocompletion pour 'bash' (version 4.x)
            ### manque le package 'bash-completion'
            #source <(SHELL=$BASH /var/www/html/occ _completion --generate-hook)
            #// lister les applications
            php occ app:list
            #// activer par exemple l'application 'External Storage Support'
            php occ app:enable files_external
            #// verifier
            php occ app:list
            #// desactiver par exemple l'application 'External Storage Support'
            php occ app:disable files_external
            #// verifier
            php occ app:list
            #// verifier la conformite de l'application 'notifications'
            php occ app:check-code notifications
            #// afficher le chemin complet de l'application 'notifications'
            php occ app:getpath notifications
            #// installer l'application 'calendar'
            php occ app:install calendar
            #// activer l'application 'calendar'
            php occ app:enable calendar
            #// installer l'application 'contacts'
            php occ app:install contacts
            #// activer l'application 'contacts'
            php occ app:enable contacts
            #// installer l'application 'spreed'
            php occ app:install spreed
            #// activer l'application 'spreed'
            php occ app:enable spreed
            #// verifier
            php occ app:list
            
            #// tester WebDav
            PASS=... #// a preciser
            curl -k -u ${COMPTE}:${PASS} "https://localhost/remote.php/dav/files/pi/" -X PROPFIND --data '<?xml version="1.0" 
            encoding="UTF-8"?>
            <d:propfind xmlns:d="DAV:">
            <d:prop xmlns:oc="http://owncloud.org/ns">
            <d:getlastmodified/>
            <d:getcontentlength/>
            <d:getcontenttype/>
            <oc:permissions/>
            <d:resourcetype/>
            <d:getetag/>
            </d:prop>
            </d:propfind>' | xmllint --format -

        #// quitter Nesxtcloud
        exit

    docker container exec --user www-data nextcloud php occ
    
    
## Nextcloud avec 'docker-compose'

### Installation

    #// installer 'docker-compose'
    apt-get install -y docker-compose
    #// passer 'docker' (apres avoir cree le compte si necessaire)
    sudo -u docker -i
        #// creer le repertoire de travail nextcloud et s'y placer
        mkdir nextcloud
        cd nextcloud
        PORT=2000
        PORT_443=$(expr $PORT \+ 443)
        POSTGRES_PASSWORD=... # a definir
        POSTGRES_USER=nextcloud
        POSTGRES_DB=nextcloud
        POSTGRES_HOST=$(hostname -I|awk '{ print $1; }')
        NEXTCLOUD_ADMIN_USER=pi
        NEXTCLOUD_ADMIN_PASSWORD=... # a definir
        #// creer le fichier 'docker-compose.yml' (supprimer les espaces au debut des lignes avant de copier)
        echo "version: '2'
         
        volumes:
          html:
          data:
          conf:
          apps:
          db:
         
        services:
          db:
            image: arm32v7/postgres
            restart: always
            volumes:
              - db:/var/lib/postgresql/data
            environment:
              - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
              - POSTGRES_USER=${POSTGRES_USER}
              - POSTGRES_DB=${POSTGRES_DB}
              - POSTGRES_HOST=${POSTGRES_HOST}
              - PGDATA=/var/lib/postgresql/data/pgdata
            ports:
              - 5432:5432
          nc:
            image: arm32v7/nextcloud
            restart: always
            ports:
              - ${PORT_443}:443
            links:
              - db
            volumes:
              - html:/var/www/html
              - data:/var/www/html/data
              - conf:/var/www/html/config
              - apps:/var/www/html/custom_apps
            environment:       
              - NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER} 
              - NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}" > docker-compose.yml 

        #// creer les services 'db' et 'nc' et les volumes associes
        docker-compose up -d
        #// installer 'Nextcloud' (supprimer les espaces au debut des lignes avant de copier)
        docker-compose exec --user www-data nc php occ  maintenance:install \
          --database "pgsql" \
          --database-host "${POSTGRES_HOST}" \
          --database-name "${POSTGRES_DB}" \
          --database-user "${POSTGRES_USER}" \
          --database-pass "${POSTGRES_PASSWORD}" \
          --admin-user "${NEXTCLOUD_ADMIN_USER}" \
          --admin-pass "${NEXTCLOUD_ADMIN_PASSWORD}"
        #// definir le fuseau horaire # (facultatif)
        docker-compose exec --user www-data nc php occ config:system:set logtimezone --value="Europe/Paris"
        #// installer les prerequis pour SSL
        docker-compose exec nc apt-get update 
        docker-compose exec nc apt-get upgrade -y
        docker-compose exec nc apt-get install -y apt-utils ssl-cert sudo libxml2-utils
        #// ajouter le compte 'www-data' au groupe 'sudo'
        docker-compose exec nc usermod -aG sudo www-data
        #// autoriser le compte 'berryboot' a utiliser 'sudo' sans mot de passe
        docker-compose exec nc sed -i -e 's/^%sudo\s\+\(ALL=(ALL:ALL)\)\s\+ALL/%sudo   ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
        #// verifier
        docker-compose exec nc cat /etc/sudoers|grep ^%sudo
        #// installer SSL (supprimer les espaces au debut des lignes)
        echo "<?php
        \$CONFIG = array (
          \"trusted_domains\" =>
          array (
            \"localhost\",
            \"${POSTGRES_HOST}:${PORT_443}\",
          ),
        );" > system.config.php
        docker cp system.config.php nextcloud_nc_1:/var/www/html/config
        docker-compose exec nc a2enmod ssl
        docker-compose exec nc a2ensite default-ssl
        docker-compose exec nc service apache2 reload
        
        #// verifier (supprimer les espaces au debut des lignes avant de copier)
        DATA="'<?xml version=\"1.0\" 
        encoding=\"UTF-8\"?>
        <d:propfind xmlns:d=\"DAV:\">
        <d:prop xmlns:oc=\"http://owncloud.org/ns\">
        <d:getlastmodified/>
        <d:getcontentlength/>
        <d:getcontenttype/>
        <oc:permissions/>
        <d:resourcetype/>
        <d:getetag/>
        </d:prop>
        </d:propfind>'"
        CMDE="curl -k -u ${NEXTCLOUD_ADMIN_USER}:${NEXTCLOUD_ADMIN_PASSWORD} 'https://localhost/remote.php/dav/files/${NEXTCLOUD_ADMIN_USER}/' -X PROPFIND --data ${DATA} | xmllint --format -"
        docker-compose exec --user www-data nc bash -c "${CMDE}"

        #// creer des utilisateurs (mot de passe creer par defaut <compte>_MdP et a changer)
        LISTE="" #// a definir (faultatif)
        for COMPTE in ${LISTE}; do docker-compose exec --user www-data nc bash -c "OC_PASS=${COMPTE}_MdP php occ user:add -n --display-name=$(echo ${COMPTE}|awk '{ print toupper(substr($1,1,1)) substr($1,2); }') --group=users --password-from-env ${COMPTE}"; done
        #// verifier
        docker-compose exec --user www-data nc php occ user:list

### Applications

    #// passer 'docker' (apres avoir cree le compte si necessaire)
    sudo -u docker -i
        LISTE="calendar contacts spreed"
        for APP in ${LISTE}; do echo APP=${APP}; docker-compose exec --user www-data nc php occ app:install ${APP}; docker-compose exec --user www-data nc php occ app:enable ${APP}; done
        #// verifier
        docker-compose exec --user www-data nc php occ app:list


### Utilisateurs

    #// passer 'docker' (apres avoir cree le compte si necessaire)
    sudo -u docker -i
        #// copier des fichiers sur un compte
        for COMPTE in ${LISTE}
        do
          echo COMPTE=${COMPTE}
          CMDE="curl -k -u ${COMPTE}:${COMPTE}_MdP 'https://localhost/remote.php/dav/files/${COMPTE}/' \
          -X PROPFIND --data ${DATA} | xmllint --format -"
          docker-compose exec --user www-data nc bash -c "${CMDE}"

          DIR=${COMPTE}/files # a definir selon les cas
          echo DIR=${DIR}
          docker cp ${DIR} nextcloud_nc_1:/var/www/html/data/${COMPTE}
          #// changer le proprietaire
          docker-compose exec nc chown -Rv www-data:www-data /var/www/html/data/${COMPTE}
          #// synchroniser les fichiers et le compte
          docker-compose exec --user www-data nc php occ files:scan ${COMPTE}
        done

        #// verifier
        docker-compose exec --user www-data nc php occ user:list
