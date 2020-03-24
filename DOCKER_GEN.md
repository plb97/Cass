# Raspberry Pi / Docker

## Docker-gen

### Lecture

* [Docker-gen](https://github.com/jwilder/docker-gen/)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # docker-gen
        BASE=${MAINTENER}/alpine
        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${APPLI}
        ' | sed -e 's/^        //' | tee env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        RUN apk add --no-cache \
            libc-dev \
            make \
            git \
            go && \
            go get github.com/robfig/glock && \
            cd ~/go/src/github.com/robfig/glock/ && \
            go build ../* && \
            alias glock="$(pwd)/glock" && \
            go get github.com/BurntSushi/toml && \        
            go get github.com/jwilder/docker-gen && \
            cd ~/go/src/github.com/jwilder/docker-gen && \
            make && \
            mv -v docker-gen /sbin && \
            cd && \
            unalias glock && \
            apk del --no-cache \
            libc-dev \
            make \
            git \
            go && \
            rm -rf ~/go            

        ENTRYPOINT ["/sbin/docker-gen"]
        ' | sed -e 's/^        //' | tee Dockerfile

### Construire l'image

    .  env.sh

    docker image build --no-cache --force-rm --build-arg "BASE=${BASE}" \
        -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Lancer le conteneur

    .  env.sh

    docker container run --privileged \
        --name ${CONTENEUR} \
        -d ${IMAGE}

### Créer le conteneur

    .  env.sh

    docker container create --privileged \
        --name ${CONTENEUR} \
        ${IMAGE}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps

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

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${CONTENEUR} ; \
    docker container rm ${CONTENEUR} ; \
    docker image rm ${IMAGE}

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a 
    docker image save -o ${IMAGE}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i ${IMAGE}.tar ; docker image tag ${IMAGE}
    rm -v ${IMAGE}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a
