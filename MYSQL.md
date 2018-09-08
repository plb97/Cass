#  Cass

## Créer une image Docker pour MySQL/MariaDB

### Lectures

* [docker-entrypoint.sh](https://github.com/ashleymcnamara/docker/blob/master/docs/reference/builder.md)
* [docker tutoriel](https://docs.docker.com/get-started/)
* 

## MySQL

### Creer le 'Dockerfile'

    MAINTENER=... # a definir
    DB=mysql

    echo "FROM arm32v7/debian:buster-slim
    
    LABEL maintener=${MAINTENER}
    
    RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${DB}-server
    
    COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh
    RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh
    
    ARG MYSQL_ADMIN_USER
    ARG MYSQL_ADMIN_PASS
    ENV ADMIN_USER=\${MYSQL_ADMIN_USER:-pi}
    ENV ADMIN_PASS=\${MYSQL_ADMIN_PASS:-raspberry}
    
    RUN sed -i -e \"s|^bind-address|#bind-address|\" /etc/mysql/mariadb.conf.d/50-server.cnf
    RUN service mysql start && mysql -e \"CREATE USER '\${ADMIN_USER}'@'%' IDENTIFIED BY '\${ADMIN_PASS}'; GRANT ALL ON *.* TO '\${ADMIN_USER}'@'%'; FLUSH PRIVILEGES;\"
    
    ENTRYPOINT [\"docker-entrypoint.sh\"]
    
    EXPOSE 3306
    VOLUME /var/lib/mysql" | sed -e 's/^\s\+//' > Dockerfile

### Creer le fichier 'docker-entrypoint.sh'

    echo '#!/bin/sh
    [ -e /var/run/mysqld/mysqld.pid ] && service mysql stop
    service mysql start && tail -f /var/run/mysqld/mysqld.pid
    ' | sed -e 's/^\s\+//' > docker-entrypoint.sh

### Creer l'image 'mysql'

    DB=mysql
    TAG=buster # a adapter
    MYSQL_ADMIN_PASS=...  # a definir
    #// construire l'image
    docker image build --build-arg "MYSQL_ADMIN_PASS=${MYSQL_ADMIN_PASS}" -t "${MAINTENER}/${DB}:${TAG}" .
    #// lancer le conteneur
    docker container run --name ${DB}_${TAG} -d -p 3306:3306 ${MAINTENER}/${DB}:${TAG}
    #// lister les conteneurs
    docker container ls -a
    #// consulter les journaux
    docker container logs ${DB}_${TAG}
    
### Administrer le conteneur et l'image

    MAINTENER=... # a definir
    DB=mysql
    TAG=buster # a adapter

    #// demarrer le conteneur
    docker start ${DB}_${TAG}
    #// utiliser le conteneur
    docker container exec -it ${DB}_${TAG} mysql -u pi -p
    #// arreter le conteneur
    docker stop ${DB}_${TAG}
    #// supprimer le conteneur
    docker container rm ${DB}_${TAG}
    
    #// sauvegarder l'image 
    docker image save -o ${DB}.tar ${MAINTENER}/${DB}:${TAG}
    #// verifier la liste des images
    docker image ls -a
    #// supprimer l'image
    docker image rm ${MAINTENER}/${DB}:${TAG}
    #// restaurer l'image
    docker image load -i ${DB}.tar
    #// verifier la liste des images
    docker image ls -a
    #// supprimer l'archive
    rm -v ${DB}.tar

    #// supprimer les images fantomes
    for i in $(di ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

## MariaDB

### Créer le scripte 'env.sh'

    echo "DB=mariadb
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # mysql
        TAG=buster-slim
    "  | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    . env.sh


### Creer le 'Dockerfile'

    . env.sh

    echo "FROM arm32v7/debian:${TAG}
    
    LABEL maintener=${MAINTENER}
    
    RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${DB}-server
    
    COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh
    RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh
    
    ARG MYSQL_ADMIN_USER
    ARG MYSQL_ADMIN_PASS
    ENV ADMIN_USER=\${MYSQL_ADMIN_USER:-pi}
    ENV ADMIN_PASS=\${MYSQL_ADMIN_PASS:-raspberry}
    
    RUN sed -i -e \"s|^bind-address|#bind-address|\" /etc/mysql/mariadb.conf.d/50-server.cnf
    RUN service mysql start && mysql -e \"CREATE USER '\${ADMIN_USER}'@'%' IDENTIFIED BY '\${ADMIN_PASS}'; GRANT ALL ON *.* TO '\${ADMIN_USER}'@'%'; FLUSH PRIVILEGES;\"
    
    ENTRYPOINT [\"docker-entrypoint.sh\"]
    
    EXPOSE 3306
    VOLUME /var/lib/mysql" | sed -e 's/^\s\+//' > Dockerfile

### Creer le fichier 'docker-entrypoint.sh'

    echo '#!/bin/sh
    [ -e /var/run/mysqld/mysqld.pid ] && service mysql stop
    service mysql start && tail -f /var/run/mysqld/mysqld.pid
    ' | sed -e 's/^\s\+//' > docker-entrypoint.sh

### Creer l'image 'mariadb'


    . env.sh
    
    #// construire l'image
    docker image build --build-arg "MYSQL_ADMIN_PASS=${MYSQL_ADMIN_PASS}" -t "${MAINTENER}/${DB}:${TAG}" .
    #// lancer le conteneur
    docker container run --name ${DB}_${TAG} -d -p 3306:3306 ${MAINTENER}/${DB}:${TAG}
    #// lister les conteneurs
    docker container ls -a
    #// consulter les journaux
    docker container logs ${DB}_${TAG}
    
### Administrer le conteneur et l'image


    #// demarrer le conteneur
    docker start ${DB}_${TAG}
    #// consulter les journaux
    docke containerr logs ${DB}_${TAG}
    #// utiliser le conteneur
    docker container exec -it ${DB}_${TAG} mysql -u pi -p
    #// arreter le conteneur
    docker stop ${DB}_${TAG}
    #// supprimer le conteneur
    docker container rm ${DB}_${TAG}
    
    #// sauvegarder l'image 
    docker image save -o ${DB}.tar ${MAINTENER}/${DB}:${TAG}
    #// verifier la liste des images
    docker image ls -a
    #// supprimer l'image
    docker image rm ${MAINTENER}/${DB}:${TAG}
    #// restaurer l'image
    docker image load -i ${DB}.tar
    #// verifier la liste des images
    docker image ls -a
    #// supprimer l'archive
    rm -v ${DB}.tar

    #// supprimer les images fantomes
    for i in $(di ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done
