#  Cass

## Création d'une image 'Docker' pour Raspberry Pi 3 : plateforme PHP+Nginx+MariaDB+FTP basée sur Alpine

### Lectures

* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # amnpf
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/amnp:${TAG}
        
        NGINX_HTTP_PORT=80
        NGINX_HTTPS_PORT=443
        NGINX_NGINX_CONF_DIR=/etc/nginx
        NGINX_DATA_DIR=/var/lib/nginx
        NGINX_PHP7_CONF_DIR=/etc/php7
        NGINX_NGINX_CONF_VOL=${NGINX_NGINX_CONF_DIR//\//-}
        NGINX_DATA_VOL=${NGINX_DATA_DIR//\//-}
        NGINX_PHP7_CONF_VOL=${NGINX_PHP7_CONF_DIR//\//-}
        
        MARIADB_DATA_DIR=/var/lib/mysql
        MARIADB_CONF_DIR=/etc/mysql
        MARIADB_ROOT_PASS=secret
        MARIADB_USER=mysql
        MARIADB_PASS=mysql
        MARIADB_MAX_ALLOWED_PACKET=200M
        MARIADB_PORT=3306
        MARIADB_CONF_VOL=${MARIADB_CONF_DIR//\//-}
        MARIADB_DATA_VOL=${MARIADB_DATA_DIR//\//-}
        
        FTP_DATA_PORT=20
        FTP_PORT=21
        SSH_PORT=22
        FTP_USER=pi
        FTP_PASS=314
        
        HOST_IP="$(ifconfig en0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        #HOST_IP="$(ip -4 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        HOST_IP6="$(ifconfig en0 2>/dev/null|grep \'\sinet6\s\'|awk \'{ print $2; }\')"
        #HOST_IP6="$(ip -6 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"

        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG FTP_DATA_PORT=20
        ARG FTP_PORT=21
        ARG SSH_PORT=22
        ARG FTP_USER=pi
        ARG FTP_PASS=314

        ENV FTP_USER=${FTP_USER} \\
            FTP_PASS=${FTP_PASS} \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            #
            # Installation de Vsftp
            #
            apk --no-cache add vsftpd openssh-server; \\
            rc-update add vsftpd default ; \\
            rc-update add sshd default ; \\
            if [ -z $(grep "^${FTP_USER}:" /etc/passwd) ]; then adduser -D -g ${FTP_USER} ${FTP_USER}; fi ; \\
            echo ${FTP_PASS} > /root/passwd.txt ; \\
            echo ${FTP_PASS} >> /root/passwd.txt ; \\
            passwd ${FTP_USER} < /root/passwd.txt ; \\
            rm -v /root/passwd.txt ; \\
            vsftpd_conf=/etc/vsftpd/vsftpd.conf ; \\
            mv -v ${vsftpd_conf} ${vsftpd_conf}.origin ; \\
            grep "^[^#]" ${vsftpd_conf}.origin > ${vsftpd_conf} ; \\
            echo "" >> ${vsftpd_conf} ; \\
            echo "seccomp_sandbox=NO" >> ${vsftpd_conf} ; \\
            echo "local_enable=YES" >> ${vsftpd_conf} ; \\
            echo "write_enable=YES" >> ${vsftpd_conf} ; \\
            echo "local_umask=022" >> ${vsftpd_conf} ; \\
            echo "" >> ${vsftpd_conf} ; \\
            echo "xferlog_file=/var/log/vsftpd.log" >> ${vsftpd_conf} ; \\
            echo "chroot_local_user=YES" >> ${vsftpd_conf} ; \\
            echo "chroot_list_enable=NO" >> ${vsftpd_conf} ; \\
            echo "allow_writeable_chroot=YES" >> ${vsftpd_conf} ; \\
            echo "" >> ${vsftpd_conf} ; \\
            echo "" >> ${vsftpd_conf} ; \\
            echo "" >> ${vsftpd_conf} ; \\
            unset vsftpd_conf ; \\
            #
            # Facultatif
            #
            apk --no-cache add nano lftp openssh-client; \\
            echo

        ENTRYPOINT ["/sbin/openrc-init"]
        
        EXPOSE ${FTP_DATA_PORT}
        EXPOSE ${FTP_PORT}
        EXPOSE ${SSH_PORT}
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

        #--build-arg "MARIADB_ROOT_PASS=${MARIADB_ROOT_PASS}" \
        #--build-arg "MARIADB_USER=${MARIADB_USER}" \
        #--build-arg "MARIADB_PASS=${MARIADB_PASS}" \
    docker image build --no-cache --rm --build-arg "BASE=${BASE}" \
        --build-arg "FTP_USER=${FTP_USER}" \
        --build-arg "FTP_PASS=${FTP_PASS}" \
        -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${MARIADB_DATA_VOL} ; docker volume create ${APPLI}${MARIADB_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${NGINX_DATA_VOL} ; \
    docker volume create ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume create ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
    docker volume create ${APPLI}${MARIADB_DATA_VOL} ; \
    docker volume create ${APPLI}${MARIADB_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${NGINX_DATA_VOL}:${NGINX_DATA_DIR} \
        -v ${APPLI}${NGINX_NGINX_CONF_VOL}:${NGINX_NGINX_CONF_DIR} \
        -v ${APPLI}${NGINX_PHP7_CONF_VOL}:${NGINX_PHP7_CONF_DIR} \
        -p ${NGINX_HTTP_PORT}:80 \
        -p ${NGINX_HTTPS_PORT}:443 \
        -v ${APPLI}${MARIADB_DATA_VOL}:${MARIADB_DATA_DIR} \
        -v ${APPLI}${MARIADB_CONF_VOL}:${MARIADB_CONF_DIR} \
        -p ${MARIADB_PORT}:3306 \
        -p ${FTP_DATA_PORT}:20 \
        -p ${FTP_PORT}:21 \
        -p ${SSH_PORT}:22 \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// Consulter les journaux
    docker container exec ${APPLI}_${TAG} cat /var/log/php7/error.log ; \
    docker container exec ${APPLI}_${TAG} cat /var/log/nginx/error.log ; \
    docker container exec ${APPLI}_${TAG} cat ${MARIADB_DATA_DIR}/error.log

    #// verifier si 'mysqld' marche (0 = oui, 1 = non)
    docker container exec ${APPLI}_${TAG} mysqladmin ping > /dev/null 2>&1 ; echo $?
    docker container exec ${APPLI}_${TAG} mysqladmin ping > /dev/null 2>&1 ; if [ $? ] ; then echo OK; else echo KO; fi
    
    #// lancer la commande 'mysql'
    docker container exec -it ${APPLI}_${TAG} mysql -u root -p
    docker container exec -it ${APPLI}_${TAG} mysql -u ${MARIADB_USER} -h ${HOST_IP} --password=${MARIADB_PASS}
    
    #// executer une commande 'mysql'
    docker container exec ${APPLI}_${TAG} mysql -u root --password=${MARIADB_ROOT_PASS} \
    -e "SELECT host, user, password FROM mysql.user;"
    docker container exec ${APPLI}_${TAG} mysql -h ${HOST_IP} -u ${MARIADB_USER} --password=${MARIADB_PASS} \
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
    docker volume rm ${APPLI}${NGINX_DATA_VOL} ; \
    docker volume rm ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
    docker volume rm ${APPLI}${MARIADB_DATA_VOL} ; \
    docker volume rm ${APPLI}${MARIADB_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${NGINX_DATA_VOL} ; \
    docker volume rm ${APPLI}${NGINX_NGINX_CONF_VOL} ; \
    docker volume rm ${APPLI}${NGINX_PHP7_CONF_VOL} ; \
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

