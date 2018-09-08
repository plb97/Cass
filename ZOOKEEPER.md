#  Cass

## Créer un conteneur Docker Zookeeper pour Raspberry Pi

### Lectures

* [intro](http://blog.xebia.fr/2015/02/24/introduction-et-demystification-de-zookeeper/)
* [arm32v6](https://hub.docker.com/r/arm32v6/zookeeper/)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
            MAINTENER=plb97
            TAG=3.4.12
    ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'zoo.cfg' 

    echo $'# zoo.cfg
        tickTime=2000
        dataDir=/home/zookeeper/data
        dataLogDir=/home/zookeeper/logs
        clientPort=2181
    ' | sed -e 's/^        //' > zoo.cfg 

### Créer le fichier 'docker-entrypoint.sh' 

    echo $'#!/bin/sh
        [ 0 = $(id -u) ] &&  gosu zookeeper sh -c "$0 $*" && exit 0
        
        [ ! -e /home/zookeeper/conf/zoo.cfg ] && cp -v /home/zookeeper/zoo.cfg.origin /home/zookeeper/conf/zoo.cfg
        cd /home/zookeeper
        
        zkServer.sh start-foreground
        exit 0' | sed -e 's/^        //' > docker-entrypoint.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'FROM arm32v7/openjdk
        
        ARG MAINTENER
        LABEL maintener=${MAINTENER}
        
        RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gosu wget
        RUN useradd -r -m -s /bin/bash -U zookeeper
        
        COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
        RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh
        
        ARG TAG
        ENV ZOOKEEPER=zookeeper-${TAG}
        ENV LINES=48
        ENV COLUMNS=160
        
        RUN wget http://mirrors.standaloneinstaller.com/apache/zookeeper/${ZOOKEEPER}/${ZOOKEEPER}.tar.gz && \\
            tar zxf ${ZOOKEEPER}.tar.gz && \\
            rm -v ${ZOOKEEPER}.tar.gz && \\
            mv ${ZOOKEEPER}/* /home/zookeeper && \\
            mkdir /home/zookeeper/data /home/zookeeper/logs && \\
            rm -rv ${ZOOKEEPER} && \\
            chown -R zookeeper:zookeeper /home/zookeeper
        ENV PATH="/home/zookeeper/bin:${PATH}"
        COPY --chown=zookeeper:zookeeper zoo.cfg /home/zookeeper/zoo.cfg.origin
        
        ENTRYPOINT ["docker-entrypoint.sh"]
        
        EXPOSE 2181
        # conguration directory
        VOLUME /home/zookeeper/conf
        # data directory
        VOLUME /home/zookeeper/data
        # logs directory
        VOLUME /home/zookeeper/logs
        
        WORKDIR /home/zookeeper
        ' \
    | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --build-arg "TAG=${TAG}" --build-arg "MAINTENER=${MAINTENER}" -t "${MAINTENER}/zookeeper:${TAG}" .
    
### Lancer le conteneur

    .  env.sh

    # creer les volumes
    docker volume create zookeeper-data
    docker volume create zookeeper-logs
    docker volume create zookeeper-conf
    docker container run --name zookeeper_${TAG} \
        -v zookeeper-conf:/home/zookeeper/conf \
        -v zookeeper-data:/home/zookeeper/data \
        -v zookeeper-logs:/home/zookeeper/logs \
        -p 2181:2181 \
        -d ${MAINTENER}/zookeeper:${TAG}
    #// consulter le journal
    docker container logs zookeeper_${TAG}
    #// aller dans le conteneur en tant que 'root'
    docker container exec -it zookeeper_${TAG} bash
    #// lancer 'cqlsh' en tant que 'zookeeper'
    HOST_IP=$(hostname -I|awk '{ print $1; }') #/ il peut y avoir plusieurs IP
    docker container exec -u zookeeper -it zookeeper_${TAG} zkCli.sh -server ${HOST_IP}:2181
    #// utiliser une commande 'cqlsh'
    docker container exec -u zookeeper zookeeper_${TAG} zkCli.sh -server ${HOST_IP}:2181 ls /
    docker container exec -u zookeeper zookeeper_${TAG} zkCli.sh -server ${HOST_IP}:2181 create /test texte
    docker container exec -u zookeeper zookeeper_${TAG} zkCli.sh -server ${HOST_IP}:2181 ls /test
    docker container exec -u zookeeper zookeeper_${TAG} zkCli.sh -server ${HOST_IP}:2181 get /test
    
    #// utiliser 'nodetool'
    docker container exec -u zookeeper zookeeper_${TAG} nodetool status
  
### Nettoyer les images
  
    .  env.sh

    docker container stop zookeeper_${TAG} ; docker container rm zookeeper_${TAG}
    docker image ls -a 
    docker image save -o zookeeper.tar ${MAINTENER}/zookeeper:${TAG}
    docker image rm ${MAINTENER}/zookeeper:${TAG}
    docker image ls -a
    docker image load -i zookeeper.tar
    docker image ls -a
    rm -v zookeeper.tar
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done
    docker image ls -a
 


