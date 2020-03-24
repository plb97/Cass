#  Cass

## Alpine

### Lectures

* [Paquets](http://dl-cdn.alpinelinux.org/alpine/v3.10/main/armv7/)
* [...](http://dl-cdn.alpinelinux.org/alpine/v3.10/community/armv7/)
*

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        #APPLI=$(basename $(pwd)) # alpine
        APPLI=alpine
        #VERS=latest
        #TAG=alpine_${VERS}
        case $(uname -m) in "x86_64") ARCH=amd64; ;; "armv7l") ARCH=arm32v7; ;; none) ARCH=unknown; ;; esac
        #BASE=${ARCH}/alpine:${VERS}
        BASE=${ARCH}/alpine
        IMAGE="${MAINTENER}/${APPLI}"
        CONTENEUR="${MAINTENER}_${APPLI}"
        COMMANDE=""
        ' | sed -e 's/^        //' | tee env.sh
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ENV LANG=C.UTF-8
        
        RUN set -ex ; \\
            apk --no-cache add openrc ; \\
            mkdir /run/openrc ; \\
            touch /run/openrc/softlevel ; \\
            # Liste des services a ecarter car posant probleme avec Docker
            list="networking hwdrivers" ; \\
            for f in ${list}; do mv -v /etc/init.d/$f /etc/init.d_$f ; done ; \\
            unset list ; \\
            ## Facultatif
            #apk --no-cache add bash nano ; \\
            echo
        
        ENTRYPOINT ["/sbin/openrc-init"]
        VOLUME /sys/fs/cgroup
        
        ' | sed -e 's/^        //' | tee Dockerfile


### Construire l'image

    .  env.sh

    docker image build --no-cache --rm --build-arg "BASE=${BASE}" -t ${IMAGE} .

    docker image inspect ${IMAGE}


### Lancer le conteneur

    .  env.sh

    docker container run --name ${CONTENEUR} -d ${IMAGE} ${COMMANDE}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${CONTENEUR}

    #// Consulter les processus actifs
    docker container exec ${CONTENEUR} ps

    #// aller dans le conteneur en tant que 'root'
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
    docker image save -o ${APPLI}.tar ${IMAGE}
    docker image rm ${IMAGE}
    docker image load -i ${APPLI}.tar
    #docker image tag ${IMAGE}:<TAG>
    rm -fv ${APPLI}.tar
    docker image ls -a
    
    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i; \
        for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm --force $c; done; di rm $i; \
    done

    docker image ls -a

