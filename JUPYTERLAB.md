#  Cass


## Création d'une image 'Docker' pour Raspberry Pi : Python3 basée sur Alpine

### Lectures

* [networks](https://w3blog.fr/2016/09/20/docker-et-ses-networks/)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        BASE=${MAINTENER}/alpine
        # APPLI=$(basename $(pwd)) # jupyterlab
        APPLI=jupyterlab
        JUPYTER_PORT=9898
        JUPYTER_USER=jovyan
        JUPYTER_WORK_DIR=/home/${JUPYTER_USER}/work
        JUPYTER_BIN_DIR=/home/${JUPYTER_USER}/bin
        JUPYTER_WORK_VOL=${APPLI}${JUPYTER_WORK_DIR//\//-}
        JUPYTER_BIN_VOL=${APPLI}${JUPYTER_BIN_DIR//\//-}

        IMAGE=${MAINTENER}/${APPLI}
        CONTENEUR=${MAINTENER}_${APPLI}
        echo BASE=${BASE}
        echo APPLI=${APPLI}
        set|grep "^JUPYTER_"        
        ' | sed -e 's/^        //' | tee env.sh
    
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'entrypoint.sh' 

    echo $'#!/bin/sh
        IP=$(ifconfig eth0|grep "inet "|cut -d ":" -f 2|cut -d " " -f 1)
        jupyter lab --no-browser \\
          --NotebookApp.allow_password_change="False" \\
          --NotebookApp.password_required="False" \\
          --NotebookApp.base_url="/jupyter/" \\
          --NotebookApp.ip="${IP}"
        ' | sed -e 's/^        //' | tee entrypoint.sh

    chmod +x entrypoint.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG user=jovyan
        ARG group=jovyan
        ARG uid=1000
        ARG gid=1000
        ARG port=8888

        ENV PATH=/home/${user}/.local/bin:/home/${user}/bin:$PATH \\
            USER_HOME=/home/${user} \\
            JUPYTER_PORT=${port} \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            mkdir -p $USER_HOME/bin $USER_HOME/work ; \\
            chown -R ${uid}:${gid} $USER_HOME ; \\
            echo répertoires créés
        COPY ./entrypoint.sh $USER_HOME/bin
        RUN set -ex ; \\
            chmod o+x $USER_HOME/bin/entrypoint.sh ; \\
            addgroup -g ${gid} ${group} ; \\
            adduser -h "$USER_HOME" -u ${uid} -G ${group} -s /bin/sh -D ${user} ; \\
            apk --no-cache upgrade ; \\
            apk --no-cache add --upgrade --virtual .build-deps build-base linux-headers gcc \\
            python3-dev musl-dev zeromq-dev freetype-dev ; \\
            # apk --no-cache add --upgrade nano ; \\
            pip3 install --upgrade pip ; \\
            echo outils installés
        RUN set -ex ; \\
            pip3 install --upgrade jupyterlab cython ;\\
            echo jupyterlab cython intallés
        RUN set -ex ; \\
            pip3 install --upgrade numpy sympy ;\\
            echo numpy sympy installés
        RUN set -ex ; \\
            pip3 install --upgrade matplotlib ;\\
            echo matplotlib installé
        RUN set -ex ; \\
            pip3 install --upgrade bottleneck numexpr ;\\
            echo bottleneck numexpr installés
        RUN set -ex ; \\
            pip3 install --upgrade pandas ;\\
            # apk --no-cache del .build-deps ;\\
            echo
        
        USER ${user}:${group}
        WORKDIR $USER_HOME/work
        VOLUME /sys/fs/cgroup $USER_HOME/work
        EXPOSE ${port}
        ENTRYPOINT ["entrypoint.sh"]
        
        ' | sed -e 's/^        //' | tee Dockerfile

### Construire l'image

    .  env.sh

    docker image build --force-rm --no-cache --build-arg "BASE=${BASE}" -t "${IMAGE}" .

    docker image inspect "${IMAGE}"

### Créer les volumes

    .  env.sh

    docker volume create ${JUPYTER_BIN_VOL}
    docker volume create ${JUPYTER_WORK_VOL}

### Lancer le conteneur

    .  env.sh

    docker container run \
        --name ${CONTENEUR} \
        -v ${JUPYTER_WORK_VOL}:${JUPYTER_WORK_DIR} \
        -p ${JUPYTER_PORT}:8888 \
        -d ${IMAGE}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// Installer des pakages alpine exemple : nano
    docker container exec ${APPLI}_${TAG} apk --no-cache add --upgrade nano

    #// Installer des pakages python
    # docker container exec ${APPLI}_${TAG} pip3 install --upgrade <package>
    
    #// Obtenir le token
    docker container exec ${APPLI}_${TAG} jupyter notebook list

    #// aller dans le conteneur en tant que 'jovyan'
    docker container exec -it ${APPLI}_${TAG} sh

    #// aller dans le conteneur en tant que 'root'
    docker container exec -u root -it ${APPLI}_${TAG} sh

    #// arreter le conteneur
    docker container stop ${APPLI}_${TAG}

    #// demarrer le conteneur
    docker container start ${APPLI}_${TAG}

    #// redemarrer le conteneur
    docker container restart ${APPLI}_${TAG}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; docker volume rm ${APPLI}${PHP7_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${PHP7_CONF_VOL} ; \
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest

### Nettoyer les images
  
    .  env.sh

    docker container stop ${CONTENEUR} ; docker container rm ${CONTENEUR}
    docker image ls -a
    docker image save -o ${APPLI}.tar ${MAINTENER}/${APPLI}
    docker image rm ${MAINTENER}/${APPLI}
    docker image load -i ${APPLI}.tar ; docker image tag ${MAINTENER}/${APPLI} ${MAINTENER}/${APPLI}:latest
    rm -v ${APPLI}.tar
    docker image ls -a

    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a


### Créer le fichier 'docker-compose.yml'

    .  env.sh

    echo "# docker-compose.yml
        version: '3'
        
        services:
              
          lab:
            build:
              context: .
              args:
                BASE: ${BASE}
            image: ${IMAGE}
            ports:
              - ${JUPYTER_PORT:-9898}:8888
            tmpfs:
              - /run
              - /run/lock
              - /tmp
            volumes:
              - /sys/fs/cgroup
              - ${JUPYTER_WORK_VOL}:${JUPYTER_WORK_DIR}
              - ${JUPYTER_BIN_VOL}:${JUPYTER_BIN_DIR}
              
        volumes:
              
            ${JUPYTER_WORK_VOL}:
              external: true
            ${JUPYTER_BIN_VOL}:
              external: true
            
        " | sed -e 's/^        //' | tee docker-compose.yml

### Créer les volumes

    docker volume create ${JUPYTER_WORK_VOL}
    docker volume inspect ${JUPYTER_WORK_VOL}|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    docker volume create ${JUPYTER_BIN_VOL}
    docker volume inspect ${JUPYTER_BIN_VOL}|grep '"Mountpoint":'|cut -d ':' -f 2|cut -d '"' -f 2
    
### Lancer le service

    docker-compose up -d
    
### Consulter les journaux

    docker-compose logs

###  Aller dans le conteneur

    docker-compose exec nc sh

### Arrêter le service

    docker-compose stop

### Copier le fichier 'docker-compose.yml' et les fichiers 'Dockerfile'

    sudo mkdir -p /etc/docker/compose/jupyterlab
    sudo cp -v docker-compose.yml Dockerfile entrypoint.sh /etc/docker/compose/jupyterlab
    sudo chown -Rv root:docker /etc/docker/compose/jupyterlab
    sudo chmod -Rv g+w /etc/docker/compose/jupyterlab

### Activer le service 'jupyterlab'

    sudo systemctl enable docker-compose@jupyterlab

### Désactiver le service 'jupyterlab'

    sudo systemctl disable docker-compose@jupyterlab

### Démarrer le service 'jupyterlab'

    sudo systemctl start docker-compose@jupyterlab

### Arrêter le service 'jupyterlab'

    sudo systemctl stop docker-compose@jupyterlab

### Redémarrer le service 'jupyterlab'

    sudo systemctl restart docker-compose@jupyterlab

### Vérifier le service 'jupyterlab'

    systemctl status docker-compose@jupyterlab
    systemctl is-active docker-compose@jupyterlab
    systemctl is-failed docker-compose@jupyterlab
    netstat -lt
