#  Cass

## Création d'une image 'Docker' pour Raspberry Pi 3 : MariaDB basée sur Alpine

### Lectures

* [Busybox](https://busybox.net/downloads/BusyBox.html)
* [Mysql Alpine](https://wiki.alpinelinux.org/wiki/MariaDB)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # mariadb
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/alpine:${TAG}
        
        MARIADB_DATA_DIR=/var/lib/mysql
        MARIADB_CONF_DIR=/etc/mysql
        MARIADB_ROOT_PASS=secret
        MARIADB_USER=mysql
        MARIADB_PASS=mysql
        MARIADB_MAX_ALLOWED_PACKET=200M
        MARIADB_PORT=3306
        MARIADB_CONF_VOL=${MARIADB_CONF_DIR//\//-}
        MARIADB_DATA_VOL=${MARIADB_DATA_DIR//\//-}
        
        HOST_IP="$(ifconfig en0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        #HOST_IP="$(ip -4 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        HOST_IP6="$(ifconfig en0 2>/dev/null|grep \'\sinet6\s\'|awk \'{ print $2; }\')"
        #HOST_IP6="$(ip -6 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #HOST_IPW="$(ifconfig wlan0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        ##HOST_IPW="$(ip -4 a show wlan0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #HOST_IPW6="$(ifconfig wlan0 2>/dev/null|grep \'\sinet6\s\'|awk \'{ print $2; }\')"
        ##HOST_IPW6="$(ip -6 a show wlan0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #DOCKER_HOST_IP="$(ifconfig docker0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        ##DOCKER_HOST="$(ip -4 a show docker0 2>/dev/null|grep inet|awk \'1==NR { print $2; }\'|awk -F/ \'{ print $1; }\')"
    
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG MARIADB_ROOT_PASS=secret
        ARG MARIADB_USER=mysql
        ARG MARIADB_PASS=mysql
        ARG MARIADB_MAX_ALLOWED_PACKET=200M

        ENV MARIADB_PORT=3306 \\
            MARIADB_DATA_DIR=/var/lib/mysql \\
            MARIADB_CONF_DIR=/etc/mysql \\
            MARIADB_ROOT_PASS=${MARIADB_ROOT_PASS} \\
            MARIADB_USER=${MARIADB_USER} \\
            MARIADB_PASS=${MARIADB_PASS} \\
            MARIADB_MAX_ALLOWED_PACKET=${MARIADB_MAX_ALLOWED_PACKET} \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            #
            # Installation de MariaDB
            #
            apk --no-cache add mariadb mariadb-client mariadb-common ; \\
            #
            # Preparation a l\'initialisation de MariaDB
            #
            mariadb_init_sql=/root/mariadb_init.sql ; \\
            touch ${mariadb_init_sql} ; \\
            # Creation des requetes d\'initialisation de MariaDB
            echo "GRANT ALL PRIVILEGES ON *.* TO ${MARIADB_USER}@\'127.0.0.1\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION;" >> ${mariadb_init_sql} ; \\
            echo "GRANT ALL PRIVILEGES ON *.* TO ${MARIADB_USER}@\'localhost\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION;" >> ${mariadb_init_sql} ; \\
            echo "GRANT ALL PRIVILEGES ON *.* TO ${MARIADB_USER}@\'::1\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION;" >> ${mariadb_init_sql} ; \\
            echo "GRANT ALL PRIVILEGES ON *.* TO ${MARIADB_USER}@\'::1\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION;" >> ${mariadb_init_sql} ; \\
            echo "GRANT ALL PRIVILEGES ON *.* TO \'${MARIADB_USER}\'@\'%.%.%.%\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION ;" >> ${mariadb_init_sql} ; \\
            echo "GRANT ALL PRIVILEGES ON *.* TO \'${MARIADB_USER}\'@\'::\' IDENTIFIED BY \'${MARIADB_PASS}\' WITH GRANT OPTION ;" >>  ${mariadb_init_sql} ; \\
            #echo "DELETE FROM mysql.user WHERE host=\'$(hostname)\';" >> ${mariadb_init_sql} ; \\
            echo "DROP DATABASE test;" >> ${mariadb_init_sql} ; \\
            echo "FLUSH PRIVILEGES;" >> ${mariadb_init_sql} ; \\
            #
            # Configuration de MariaDB
            #
            cp -v ${MARIADB_CONF_DIR}/my.cnf ${MARIADB_CONF_DIR}/my.cnf.origin ; \\
            sed -i -e "s|^\[mysqld\]|[mysqld]\\nlog-error = error\\.log|g" ${MARIADB_CONF_DIR}/my.cnf ; \\
            sed -i -e "s|max_allowed_packet\s*=\s*1M|max_allowed_packet = ${MARIADB_MAX_ALLOWED_PACKET}|g" ${MARIADB_CONF_DIR}/my.cnf ; \\
            sed -i -e "s|max_allowed_packet\s*=\s*16M|max_allowed_packet = ${MARIADB_MAX_ALLOWED_PACKET}|g" ${MARIADB_CONF_DIR}/my.cnf ; \\
            #grep \'^[^#]\' ${MARIADB_CONF_DIR}/my.cnf ; \\
            #
            # Initialisation de MariaDB
            #
            chmod o+w /var/tmp ; \\
            mysql_install_db --rpm --user=mysql --datadir="${MARIADB_DATA_DIR}" ; \\
            mysqld_safe --user=mysql --datadir="${MARIADB_DATA_DIR}" & sleep 2 ; \\
            mysqladmin -u root password "${MARIADB_ROOT_PASS}" ; \\
            cat ${mariadb_init_sql} | mysql -u root --password="${MARIADB_ROOT_PASS}" ; \\
            mysql -u root --password="${MARIADB_ROOT_PASS}" -e "DELETE FROM mysql.user WHERE host=\'$(hostname)\';" ; \\
            mysqlcheck -u root --password="${MARIADB_ROOT_PASS}" --repair --all-databases ; \\
            unset mariadb_init_sql ; \\
            rc-update add mariadb default ; \\
            echo

        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${MARIADB_DATA_DIR}
        VOLUME ${MARIADB_CONF_DIR}
        EXPOSE ${MARIADB_PORT}
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --rm --build-arg "BASE=${BASE}" \
        --build-arg "MARIADB_ROOT_PASS=${MARIADB_ROOT_PASS}" \
        --build-arg "MARIADB_USER=${MARIADB_USER}" \
        --build-arg "MARIADB_PASS=${MARIADB_PASS}" \
        -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${MARIADB_DATA_VOL} ; docker volume create ${APPLI}${MARIADB_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${MARIADB_DATA_VOL} ; \
    docker volume create ${APPLI}${MARIADB_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${MARIADB_DATA_VOL}:${MARIADB_DATA_DIR} \
        -v ${APPLI}${MARIADB_CONF_VOL}:${MARIADB_CONF_DIR} \
        -p ${MARIADB_PORT}:3306 \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// verifier si 'mysqld' marche (0 = oui, 1 = non)
    docker container exec ${APPLI}_${TAG} mysqladmin ping > /dev/null 2>&1 ; echo $?
    docker container exec ${APPLI}_${TAG} mysqladmin ping > /dev/null 2>&1 ; if [ $? ] ; then echo OK; else echo KO; fi
    
    #// Consulter le journal
    docker container exec ${APPLI}_${TAG} cat ${MARIADB_DATA_DIR}/error.log

    #// lancer la commande 'mysql'
    docker container exec -it ${APPLI}_${TAG} mysql -u root -p
    docker container exec -it ${APPLI}_${TAG} mysql -u ${MARIADB_USER} -h ${HOST_IP} --password=${MARIADB_PASS}
    
    #// executer une commande 'mysql'
    docker container exec ${APPLI}_${TAG} mysql -u root --password=${MARIADB_ROOT_PASS} \
    -e "SELECT host, user, password FROM mysql.user;"
    docker container exec ${APPLI}_${TAG} mysql -u ${MARIADB_USER} -h ${HOST_IP} --password=${MARIADB_PASS} \
    -e "SELECT host, user, password FROM mysql.user;"

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
    docker volume rm ${APPLI}${MARIADB_DATA_VOL} ; \
    docker volume rm ${APPLI}${MARIADB_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${MARIADB_DATA_VOL} ; \
    docker volume rm ${APPLI}${MARIADB_CONF_VOL} ; \
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

