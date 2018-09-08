#  Cass

## Intallation de Cassandra sur une Raspberry Pi 3

* [Installation sur Debian de Cassandra](http://cassandra.apache.org/download/)
* [fstab](https://manpages.debian.org/stretch/manpages-fr-extra/fstab.5.fr.html)
* [bash](http://wiki.bash-hackers.org/syntax/quoting)
* [bash](http://wiki.bash-hackers.org/syntax/pe)
* [bash](http://wiki.bash-hackers.org/syntax/pattern)
*

Voir [Montage automatique disques USB ou DVD](RASPBERRYPI3.md).

    #// passer 'root'
    sudo -i
        #// creer un lien entre le disque USB et /home/shares
        DIR=/home/shares
        echo DIR=${DIR}
        PARTUUID=$(ls -x /media/disk/|awk '{print $1}') # premier disque USB
        echo PARTUUID=${PARTUUID}
        ln -s /media/disk/${PARTUUID} ${DIR}

        #// mettre a jour l'installation
        apt-get update
        apt-get upgrade
        apt-get dist-upgrade

        apt-get install wget openjdk-8-jdk
        #// creer un utilisateur 'cassandra'
        COMPTE="cassandra"
        echo COMPTE=${COMPTE}
        do adduser --disabled-login --disabled-password --home ${DIR}/${COMPTE} ${COMPTE}; usermod -aG users ${COMPTE};

        ### Récupération du paquet Cassandra

        #// definir la version
        RELEASE=3.11.1
        #// choisir un miroir
        MIRROR=http://wwwftp.ciril.fr/pub/apache
        #MIRROR=http://www-eu.apache.org/dist # si aucun miroir trouve ou operationnel
        #// recuperer l'archive de Cassandra
        wget ${MIRROR}/cassandra/${RELEASE}/apache-cassandra-${RELEASE}-bin.tar.gz
        #// decompresser l'archive de Cassandra
        tar -xvf apache-cassandra-${RELEASE}-bin.tar.gz
        #// creer un lien 'cassandra'
        ln -s apache-cassandra-${RELEASE} cassandra
        #// verifier le lien
        ls -l cassandra/bin
        #// ajouter Cassandra dans le 'PATH'
        echo 'export PATH=${HOME}/cassandra/bin:${PATH}' >> ${HOME}/.profile
        #// mettre a jour le 'PATH' de la session
        source ${HOME}/.profile
        #// tester Cassandra en avant-plan
        cassandra -f
        ^C
        #// demarrer Cassandra en arriere-plan
        cassandra > cassandra.log
        tail -f cassandra.log
        ^C
        #// verifier le bon fonctionnement de Cassandra avec 'nodetool'
        nodetool status
        #// verifier le bon fonctionnement de Cassandra avec 'cqlsh'
        cqlsh
        SELECT cluster_name, listen_address, host_id FROM system.local;
        quit

        #// arreter doucement le processus Cassandra
        nodetool stopdaemon
        ##// forcer brutalement l'arret complet de Cassandra
        for pid in $(ps -x|grep -v grep|grep CassandraDaemon|awk '{ print $1;}'); do kill $pid; done

        ### Modification de la configuration

        La Raspeberry Pi 3 dispose de deux interfaces réseau :

        - ethernet : 'eth0'
        - wifi : 'wlan0'

        Cette caractéristique peut être utilisée pour, par exemple, affecter l'interface 'eth0' à l'écoute des partenaires (listen_interface) et l'interface 'wlan0' à l'écoute des clients (rpc_interface).
        Naturellemnt, cela suppose que carte ethernet est reliée par câble au réseau et que le wifi est activé.

        #// lister les interfaces actives et les adresses associees
        ip -4 -o addr|grep 'scope global'|awk '{ print $2, $4; }'|awk -F/ '{ print $1; }'
        #// verifier l'arret du processus Cassandra
        nodetool status

        #// definir les fichiers de configuration (a adapter si necessaire ou souhaite)
        CONFIG=cassandra/conf/cassandra.yaml
        OPTIONS=cassandra/conf/jvm.options
        #// sauvegarder les configurations d'origine
        cp -v ${CONFIG} ${CONFIG}.origin
        cp -v ${OPTIONS} ${OPTIONS}.origin

        ##// changer le parametre de memoire de la JVM (#-Xms4G)
        cat ${OPTIONS}|grep "^#\?-Xms.\+"
        sed -i -e "s/^#\?-Xms.\+/-Xms500M/g" ${OPTIONS}
        cat ${OPTIONS}|grep "^#\?-Xms.\+"
        ##// changer le parametre de memoire de la JVM (#-Xmx4G)
        cat ${OPTIONS}|grep "^#\?-Xmx.\+"
        sed -i -e "s/^#\?-Xmx.\+/-Xmx500M/g" ${OPTIONS}
        cat ${OPTIONS}|grep "^#\?-Xmx.\+"
        ##// changer le parametre de memoire de la JVM (#-Xmn800M)
        cat ${OPTIONS}|grep "^#\?-Xmn.\+"
        sed -i -e "s/^#\?-Xmn.\+/-Xmn100M/g" ${OPTIONS}
        cat ${OPTIONS}|grep "^#\?-Xmn.\+"

        #// autoriser les procedures stockees utilisateurs (facultatif)
        cat ${CONFIG}|grep "^enable_user_defined_functions:"
        sed -i -e "s/^enable_user_defined_functions: /enable_user_defined_functions: true #/g" ${CONFIG}
        cat ${CONFIG}|grep "^enable_user_defined_functions:"
        #// autoriser l'autentification par 'user/password' (facultatif)
        cat ${CONFIG}|grep "^authenticator:"
        sed -i -e "s/^authenticator: /authenticator: PasswordAuthenticator #/g" ${CONFIG}
        cat ${CONFIG}|grep "^authenticator:"

        ##// premiere possibilite (a titre d'exemple)
        ###// choisir la premiere adresse IP (ou une autre manuellement)
        ##ADDR=$(hostname -I|awk '{print $1;}')
        ## APART=${ADDR}
        ##echo APART=${APART}
        ## ACLIENT=${ADDR}
        ##echo ACLIENT=${ACLIENT}
        ###// changer l'adresse d'ecoute pour les partenaires
        ##cat ${CONFIG}|grep '^listen_address: '
        ##sed -i -e "s/^listen_address: /listen_address: ${APART} #/g" ${CONFIG}
        ##cat ${CONFIG}|grep '^listen_address: '
        ###// changer l'adresse d'ecoute pour les clients (protocoles 'natif' et 'thrift')
        ##cat ${CONFIG}|grep '^rpc_address: '
        ##sed -i -e "s/^rpc_address: /rpc_address: ${ACLIENT} #/g" ${CONFIG}
        ##cat ${CONFIG}|grep '^rpc_address: '
        ###// definir la liste des partenaires
        ##...
        ##// deuxieme possibilite (a titre d'exemple)
        #// lister les interfaces ethernet et les adresses IPv4 liees
        for iface in $(ifconfig -s|grep -v "^Iface "|grep -v "^lo "|awk '{print $1;}'); do ifconfig $iface|grep 'inet '|awk -v iface=$iface '{print iface, $2;}'; done
        #// definir l'interface pour les partenaires
        IPART="eth0" # a adapter si necessaire ou souhaite
        echo IPART=${IPART}
        APART=$(for iface in $(ifconfig -s|grep -v "^Iface "|grep -v "^lo "|awk '{print $1;}'); do ifconfig $iface|grep 'inet '|awk -v iface=$iface '{print iface, $2;}'|grep ${IPART}|awk '{print $2;}'; done)
        echo APART=${APART}
        #// definir l'interface pour les clients
        ICLIENT="wlan0" # a adapter si necessaire ou souhaite
        echo ICLIENT=${ICLIENT}
        ACLIENT=$(for iface in $(ifconfig -s|grep -v "^Iface "|grep -v "^lo "|awk '{print $1;}'); do ifconfig $iface|grep 'inet '|awk -v iface=$iface '{print iface, $2;}'|grep ${ICLIENT}|awk '{print $2;}'; done)
        echo ACLIENT=${ACLIENT}
        #// mettre en commentaire l'option 'listen_address'
        cat ${CONFIG}|grep '^listen_address: '
        sed -i -e "s/^listen_address: /# listen_address: /g" ${CONFIG}
        cat ${CONFIG}|grep '^# listen_address: '
        #// definir l'interface d'ecoute pour les partenaires
        cat ${CONFIG}|grep '^# listen_interface: '
        sed -i -e "s/^# listen_interface: /listen_interface: ${IPART} #/g" ${CONFIG}
        cat ${CONFIG}|grep '^listen_interface: '
        #// mettre en commentaire l'option 'rpc_address'
        cat ${CONFIG}|grep '^rpc_address: '
        sed -i -e "s/^rpc_address: /# rpc_address: /g" ${CONFIG}
        cat ${CONFIG}|grep '^# rpc_address: '
        #// definir l'interface d'ecoute pour les clients (protocoles 'natif' et 'thrift')
        cat ${CONFIG}|grep '^# listen_interface: '
        sed -i -e "s/^# rpc_interface: /rpc_interface: ${ICLIENT} #/g" ${CONFIG}
        cat ${CONFIG}|grep '^listen_interface: '

        #// definir la liste des partenaires
        HOSTS=${APART} #  ("noeud1, noeud2, ..." si necessaire ou prefere)
        echo HOSTS=${HOSTS}
        cat ${CONFIG}|grep '^          - seeds: '
        sed -i -e "s/^          - seeds: \"127.0.0.1\"/          - seeds: \"${HOSTS}\" #\"127.0.0.1\"/g" ${CONFIG}
        cat ${CONFIG}|grep '^          - seeds: '

        #// demarrer Cassandra en arriere-plan
        cassandra > cassandra.log
        tail -f cassandra.log
            ^C
        #// verifier le bon fonctionnement de Cassandra avec 'nodetool'
        nodetool status
        #// verifier le bon fonctionnement de Cassandra avec 'cqlsh'
        #// en local ou sur une autre machine du meme reseau sans oublier de definir 'ACLIENT' dans ce cas
        cqlsh ${ACLIENT} -u cassandra -p cassandra
        SELECT cluster_name, listen_address, host_id FROM system.local;
        quit

        #// Afficher l'identifiant du processus Cassandra
        ps -x|grep CassandraDaemon|grep -v grep|awk '{ print $1;}'



## Créer un conteneur Docker Cassandra pour Raspberry Pi
        
### Créer le fichier 'env.sh' 
        
    echo $'
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # cassandra2
        TAG=3.11.2
        #CONF_DIR=/home/cassandra/conf
        #DATA_DIR=/home/cassandra/data
        #STORAGE_PORT=7000
        #SSL_STORAGE_PORT=7001
        #JMX_PORT=7199
        #NATIVE_TRANSPORT_PORT=9042
        #SSL_NATIVE_TRANSPORT_PORT=9142
        #JDK8=jdk-8u171-fcs-bin-b11-linux-arm32-vfp-hflt.tar.gz
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    . env.sh
        
### Créer le fichier 'docker-entrypoint.sh' 

    echo $'#!/bin/sh
        [ 0 = $(id -u) ] &&  gosu cassandra sh -c "$0 $*" && exit 0
        
        #HOST_IP=$(hostname -I|awk \'{ print $1; }\')
        HOST_IP=$(hostname -i)
        #HOST_IP=$(ifconfig eth0|grep \'\sinet\s\'|awk \'{ print $2; }\'|sed -e \'s|^addr:||g\')
        #HOST_IP=$(ip -4 a show eth0|grep \'\sinet\s\'|awk \'1==NR { print $2; }\'|sed -e \'s|/[0-9]\+||g\')
        
        CONFIG=${CONF_DIR}/cassandra.yaml
        
        # restaurer la configuration d\'origine
        cp -v ${CONFIG}.origin ${CONFIG}
        ## autoriser les procedures stockees utilisateurs (facultatif)
        grep "^enable_user_defined_functions:" ${CONFIG}
        sed -i -e "s/^enable_user_defined_functions: /enable_user_defined_functions: true #/g" ${CONFIG}
        grep "^enable_user_defined_functions:" ${CONFIG}
        ## autoriser l\'autentification par \'user/password\' (facultatif)
        grep "^authenticator:" ${CONFIG}
        sed -i -e "s/^authenticator: /authenticator: PasswordAuthenticator #/g" ${CONFIG}
        grep "^authenticator:" ${CONFIG}
        ## changer l\'IP de \'listen_address\'
        grep "^listen_address: " ${CONFIG}
        sed -i -e "s/^listen_address: /listen_address: ${HOST_IP} #/g" ${CONFIG}
        grep "^listen_address: " ${CONFIG}
        ## changer l\'IP de \'rpc_address\'
        grep "^rpc_address: " ${CONFIG}
        sed -i -e "s/^rpc_address: /rpc_address: ${HOST_IP} #/g" ${CONFIG}
        grep "^rpc_address: " ${CONFIG}
        ## changer l\'IP des \'seeds\'
        grep "^          - seeds: " ${CONFIG}
        sed -i -e "s/^          - seeds: /          - seeds: \\"${HOST_IP}\\" #/g" ${CONFIG}
        grep "^          - seeds: " ${CONFIG}
        grep ":\s\+7000\s*$" ${CONFIG}
        sed -e "s=:\s\+7000\s*=: ${STORAGE_PORT}=g" ${CONFIG}
        grep ": ${STORAGE_PORT}" ${CONFIG}
        grep ":\s\+7001\s*$" ${CONFIG}
        sed -e "s=:\s\+7001\s*=: ${SSL_STORAGE_PORT}=g" ${CONFIG}
        grep ": ${SSL_STORAGE_PORT}" ${CONFIG}
        grep ":\s\+7199\s*$" ${CONFIG}
        sed -e "s=:\s\+7199\s*=: ${JMX_PORT}=g" ${CONFIG}
        grep ": ${JMX_PORT}" ${CONFIG}
        grep ":\s\+9042\s*$" ${CONFIG}
        sed -e "s=:\s\+9042\s*=: ${NATIVE_TRANSPORT_PORT}=g" ${CONFIG}
        grep ": ${NATIVE_TRANSPORT_PORT}" ${CONFIG}
        grep ":\s\+9142\s*$" ${CONFIG}
        sed -e "s=:\s\+9142\s*=: ${SSL_NATIVE_TRANSPORT_PORT}=g" ${CONFIG}
        grep ": ${SSL_NATIVE_TRANSPORT_PORT}" ${CONFIG}
        
        #OPTIONS=${CONF_DIR}/jvm.options
        ## restaurer la configuration d\'origine
        #cp -v ${OPTIONS}.origin ${OPTIONS}
        ### changer le parametre de memoire de la JVM (#-Xms4G)
        #grep "^#\\?-Xms.\+" ${OPTIONS}
        #sed -i -e "s/^#\\?-Xms.\+/-Xms500M/g" ${OPTIONS}
        #grep "^#\\?-Xms.\+" ${OPTIONS}
        ### changer le parametre de memoire de la JVM (#-Xmx4G)
        #grep "^#\\?-Xmx.\+" ${OPTIONS}
        #sed -i -e "s/^#\\?-Xmx.\+/-Xmx500M/g" ${OPTIONS}
        #grep "^#\\?-Xmx.\+" ${OPTIONS}
        ### changer le parametre de memoire de la JVM (#-Xmn800M)
        #grep "^#\\?-Xmn.\+" ${OPTIONS}
        #sed -i -e "s/^#\\?-Xmn.\+/-Xmn200M/g" ${OPTIONS}
        #grep "^#\\?-Xmn.\+" ${OPTIONS}
        
        #cassandra -f -p /home/cassandra/run/cassandra.pid
        #tail -f /etc/hostname
        exec "$@"
        ' | sed -e 's/^        //' > docker-entrypoint.sh

### Creer le fichier 'Dockerfile'

    . env.sh

    echo $'FROM arm32v7/openjdk
        
        RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gosu wget
        RUN useradd -r -m -s /bin/bash -U cassandra
        
        COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
        RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh
        
        ARG TAG
        ARG CONF_DIR=/home/cassandra/conf
        ARG DATA_DIR=/home/cassandra/data
        ARG STORAGE_PORT=7000
        ARG SSL_STORAGE_PORT=7001
        ARG JMX_PORT=7199
        ARG NATIVE_TRANSPORT_PORT=9042
        ARG SSL_NATIVE_TRANSPORT_PORT=9142
        
        ENV CASSANDRA=apache-cassandra-${TAG} \\
            CONF_DIR=${CONF_DIR} \\
            DATA_DIR=${DATA_DIR} \\
            STORAGE_PORT=${STORAGE_PORT} \\
            SSL_STORAGE_PORT=${SSL_STORAGE_PORT} \\
            JMX_PORT=${JMX_PORT} \\
            NATIVE_TRANSPORT_PORT=${NATIVE_TRANSPORT_PORT} \\
            SSL_NATIVE_TRANSPORT_PORT=${SSL_NATIVE_TRANSPORT_PORT} \\
            LANG=C.UTF-8
        
        RUN wget http://mirrors.standaloneinstaller.com/apache/cassandra/${TAG}/${CASSANDRA}-bin.tar.gz && \\
            tar zxf ${CASSANDRA}-bin.tar.gz && \\
            rm -v ${CASSANDRA}-bin.tar.gz && \\
            mv ${CASSANDRA}/* /home/cassandra && \\
            cp -v ${CONF_DIR}/cassandra.yaml ${CONF_DIR}/cassandra.yaml.origin && \\
            cp -v ${CONF_DIR}/jvm.options ${CONF_DIR}/jvm.options.origin && \\
            mkdir ${DATA_DIR} /home/cassandra/logs /home/cassandra/run && \\
            rm -rv ${CASSANDRA} && \\
            chown -R cassandra:cassandra /home/cassandra

        ENV PATH="/home/cassandra/bin:${PATH}"
        
        EXPOSE ${STORAGE_PORT}
        EXPOSE ${SSL_STORAGE_PORT}
        EXPOSE ${NATIVE_TRANSPORT_PORT}
        EXPOSE ${SSL_NATIVE_TRANSPORT_PORT}
        EXPOSE ${JMX_PORT}
        
        VOLUME ${CONF_DIR}
        VOLUME ${DATA_DIR}
        
        WORKDIR /home/cassandra
        
        ENTRYPOINT ["docker-entrypoint.sh"]
        CMD ["cassandra", "-f", "-p", "/home/cassandra/run/cassandra.pid"]
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    . env.sh
    
    docker image build --build-arg "TAG=${TAG}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .
    
### Supprimer le conteneur
    
    . env.sh
    
    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}

### Supprimer les volumes

    . env.sh

    docker volume rm ${APPLI}-data && docker volume rm ${APPLI}-conf
    
### Créer les volumes
    
    . env.sh
    
    docker volume create ${APPLI}-data && docker volume create ${APPLI}-conf
    
### Lancer le conteneur

    . env.sh

    docker container run --name ${APPLI}_${TAG} \
        -v ${APPLI}-conf:/home/cassandra/conf \
        -v ${APPLI}-data:/home/cassandra/data \
        -p 7000:7000 -p 7001:7001 -p 9042:9042 -p 9142:9142 -p 7199:7199 \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it ${APPLI}_${TAG} bassh

    #// arreter le conteneur
    docker container stop ${APPLI}_${TAG}

    #// demarrer le conteneur
    docker container start ${APPLI}_${TAG}

    #// redemarrer le conteneur
    docker container restart ${APPLI}_${TAG}

    #// lancer 'cqlsh' en tant que 'cassandra'
    #eval $(ip -o -4 addr show|grep enx|awk '1==NR { print "ETH=" $2, "ETH_IP=" substr($4,1,index($4,"/")-1); }')
    #echo ETH=${ETH} ETH_IP=${ETH_IP}
    #eval $(ip -o -4 addr show|grep wlx|awk '1==NR { print "WLAN=" $2, "WLAN_IP=" substr($4,1,index($4,"/")-1); }')
    #echo WLAN=${WLAN} WLAN_IP=${WLAN_IP}
    #HOST_IP=$(hostname -i)
    HOST_IP=$(ifconfig eth0|grep ' inet '|awk '{ print $2; }'|sed -e 's|^addr:||g')
    #HOST_IP=$(ip -4 a show eth0|grep ' inet '|awk '1==NR { print $2; }'|sed -e 's|/[0-9]\+||g')
    docker container exec -u cassandra -it ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra
    #// utiliser une commande 'cqlsh'
    docker container exec -u cassandra ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra -e "describe keyspaces"
    docker container exec -u cassandra ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra -e \
        "CREATE KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3};"
    docker container exec -u cassandra ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra -e "describe keyspace test"
    docker container exec -u cassandra ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra -e \
        "CREATE TABLE test.essai ( cle text PRIMARY KEY, texte text );"
    docker container exec -u cassandra ${APPLI}_${TAG} cqlsh ${HOST_IP} -u cassandra -p cassandra -e "describe table test.essai"
    sudo ls -la /var/lib/docker/volumes/${APPLI}-data/_data/data/test
    sudo ls -la /var/lib/docker/volumes/${APPLI}-conf/_data/
    
    #// utiliser 'nodetool'
    docker container exec -u cassandra https://github.com/apple/swift${TAG} nodetool status
  
### Nettoyer les images
  
    MAINTENER=... # a definir
    TAG=3.11.2

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}
    docker image ls -a 
    docker image save -o ${APPLI}.tar ${MAINTENER}/${APPLI}:${TAG}
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    docker image ls -a
    docker image load -i ${APPLI}.tar
    docker image tag ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    docker image ls -a
    rm -v ${APPLI}.tar
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done
    docker image ls -a
 
