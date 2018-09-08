#  Cass

## Création d'une image 'Docker' pour Raspberry Pi 3 : Cassandra basée sur Alpine


### Lectures

* [ Oracle JDK](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html )
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # cassandra
        VERS=8-jre-alpine3.7
        TAG=alpine_${VERS}
        REL=3.11.2
        CONF_DIR=/home/cassandra/conf
        DATA_DIR=/home/cassandra/data
        #JDK8=jdk-8u171-fcs-bin-b11-linux-arm32-vfp-hflt.tar.gz
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'docker-entrypoint.sh' 

    echo $'#!/bin/sh
        set -ex
        whoami
        [ 0 = $(id -u) ] && su-exec cassandra sh -c "$0 $*" && exit 0
        set -ex
        whoami
        #eval $(ip -o -4 addr show|grep enx|awk '1==NR { print "ETH=" $2, "ETH_IP=" substr($4,1,index($4,"/")-1); }')
        #echo ETH=${ETH} ETH_IP=${ETH_IP}
        #eval $(ip -o -4 addr show|grep wlx|awk '1==NR { print "WLAN=" $2, "WLAN_IP=" substr($4,1,index($4,"/")-1); }')
        #echo WLAN=${WLAN} WLAN_IP=${WLAN_IP}
        HOST_IP=$(hostname -i)
        #HOST_IP=$(ifconfig eth0|grep \'\sinet\s\'|awk \'{ print $2; }\'|sed -e \'s|^addr:||g\')
        #HOST_IP=$(ip -4 a show eth0|grep \'\sinet\s\'|awk \'{ print $2; }\'|sed -e \'s|/[0-9]\+||g\')
        if [ "" = "${HOST_IP}" ]
        then
            echo "HOST_IP=\'\'"
            exit 1
        fi
        
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
        #### changer le parametre de memoire de la JVM (#-Xmx4G)
        #grep "^#\\?-Xmx.\+" ${OPTIONS}
        #sed -i -e "s/^#\\?-Xmx.\+/-Xmx500M/g" ${OPTIONS}
        #grep "^#\\?-Xmx.\+" ${OPTIONS}
        ### changer le parametre de memoire de la JVM (#-Xmn800M)
        #grep "^#\\?-Xmn.\+" ${OPTIONS}
        #sed -i -e "s/^#\\?-Xmn.\+/-Xmn200M/g" ${OPTIONS}
        #grep "^#\\?-Xmn.\+" ${OPTIONS}
        
        cassandra -f -p /home/cassandra/run/cassandra.pid
        #tail -f /etc/hostname
        ' | sed -e 's/^        //' > docker-entrypoint.sh


### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG VERS
        FROM openjdk:${VERS}
        
        COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
        RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh
        
        ARG REL
        ENV CASSANDRA=apache-cassandra-${REL} \\
            CONF_DIR=/home/cassandra/conf \\
            DATA_DIR=/home/cassandra/data \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            apk --no-cache add su-exec dpkg ; \\
            addgroup -S cassandra ; \\
            adduser -h /home/cassandra -s /bin/sh -S -D -G cassandra cassandra
        
        ARG STORAGE_PORT=7000
        ARG SSL_STORAGE_PORT=7001
        ARG NATIVE_TRANSPORT_PORT=9042
        ARG SSL_NATIVE_TRANSPORT_PORT=9142
        ARG JMX_PORT=7199

        #ARG JDK8
        #COPY ${JDK8} /usr/lib/jvm/
        #RUN -ex; \\
        #   cd /usr/lib/jvm/ ;\\
        #    tar zxvf ${JDK8} ; \\
        ##    unlink default-jvm ; \\
        ##    ln -sv jdk1.8.0 default-jvm ; \\
        #    rm -v ${JDK8} ; \\
        #    jdk8=$(pwd)/$(ls -1 -d jdk1.8.0_*) ; \\
        ##    chmod -v a+x ${jdk8}/bin/* ; \\
        ##    chown -Rv root:root ${jdk8} ; \\
        #    ln -sv ${jdk8} /usr/lib/jvm/jdk1.8.0 ; \\
        #    update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_171/bin/java" 1 ; \\
        #    update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_171/bin/javac" 1 ; \\
        #    update-alternatives --config java
        
        RUN set -ex; \\
            wget http://mirrors.standaloneinstaller.com/apache/cassandra/${REL}/${CASSANDRA}-bin.tar.gz ; \\
            tar zxf ${CASSANDRA}-bin.tar.gz ; \\
            rm -v ${CASSANDRA}-bin.tar.gz ; \\
            mv ${CASSANDRA}/* /home/cassandra ; \\
            cp -v ${CONF_DIR}/cassandra.yaml ${CONF_DIR}/cassandra.yaml.origin ; \\
            cp -v ${CONF_DIR}/jvm.options ${CONF_DIR}/jvm.options.origin ; \\
            mkdir -p ${DATA_DIR} /home/cassandra/logs /home/cassandra/run ; \\
            rm -rv ${CASSANDRA} ; \\
            chown -R cassandra:cassandra /home/cassandra

        ENV PATH="/home/cassandra/bin:${PATH}"
        
        ENTRYPOINT ["docker-entrypoint.sh"]
        
        EXPOSE ${STORAGE_PORT}
        EXPOSE ${SSL_STORAGE_PORT}
        EXPOSE ${JMX_PORT}
        EXPOSE ${NATIVE_TRANSPORT_PORT}
        EXPOSE ${SSL_NATIVE_TRANSPORT_PORT}
        
        VOLUME ${CONF_DIR}
        VOLUME ${DATA_DIR}
        
        WORKDIR /home/cassandra

        ' | sed -e 's/^        //' > Dockerfile


### Construire l'image

    .  env.sh

    docker image build --build-arg "VERS=${VERS}" --build-arg "REL=${REL}" -t "${MAINTENER}/cassandra:${TAG}" -t "${MAINTENER}/cassandra:latest" .
    docker image inspect "${MAINTENER}/cassandra:${TAG}"
    
### Créer les volumes

    docker volume create cassandra-data && docker volume create cassandra-conf

### Lancer le conteneur

    .  env.sh

    docker container run --name cassandra_${TAG} \
        -v cassandra-data:${DATA_DIR} \
        -v cassandra-conf:${CONF_DIR} \
        -p 7000:7000 \
        -p 7001:7001 \
        -p 7199:7199 \
        -p 9042:9042 \
        -p 9142:9142 \
        -d ${MAINTENER}/cassandra:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs cassandra_${TAG}

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it cassandra_${TAG} sh

    #// arreter le conteneur
    docker container stop cassandra_${TAG}

    #// demarrer le conteneur
    docker container start cassandra_${TAG}

    #// redemarrer le conteneur
    docker container restart cassandra_${TAG}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop cassandra_${TAG} ; docker container rm cassandra_${TAG} ; docker volume rm cassandra-data && docker volume rm cassandra-conf

### Nettoyer les images
  
    .  env.sh

    docker container stop cassandra_${TAG} ; docker container rm cassandra_${TAG}
    docker image ls -a 
    docker image save -o cassandra.tar ${MAINTENER}/cassandra:${TAG}
    docker image rm ${MAINTENER}/cassandra:${TAG} ${MAINTENER}/cassandra:latest
    docker image ls -a
    docker image load -i cassandra.tar
    docker image tag ${MAINTENER}/cassandra:${TAG} ${MAINTENER}/cassandra:latest
    docker image ls -a
    rm -v cassandra.tar
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done
    docker image ls -a
