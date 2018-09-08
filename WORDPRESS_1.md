#  Cass


### Créer le fichier 'env.sh'

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # wordpress
        MYSQL_USER=pi
        MYSQL_PASSWORD=raspberry
        MYSQL_ROOT_PASSWORD=mysecret
        HOST_IP="$(ifconfig eth0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        HOST_IPW="$(ifconfig wlan0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        DB_HOST="$(ifconfig docker0 2>/dev/null|grep \'\sinet\s\'|awk \'1==NR { print $2; }\')"
        MYSQL_PORT=3366
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Créer le fichier 'docker-compose.yml' 

    . env.sh
    
    echo "version: '2'

        volumes:
          data:
          conf:
          html:

        services:
          db:
            image: plb97/mariadb:alpine_3.7
            restart: always
            volumes:
                - data:/var/lib/mysql
                - conf:/etc/mysql
            environment:
                - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
                - MYSQL_USER=${MYSQL_USER}
                - MYSQL_PASSWORD=${MYSQL_PASSWORD}
            ports:
                - ${MYSQL_PORT}:3306
          wp:
            image: arm32v7/wordpress
            restart: always
            volumes:
                - html:/var/www/html
            ports:
                - 8080:80
            links:
                - db
            environment:
                - WORDPRESS_DB_HOST=${DB_HOST}
                - WORDPRESS_DB_USER=${MYSQL_USER}
                - WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
                - WORDPRESS_DB_NAME=wordpress
                - WORDPRESS_TABLE_PREFIX=${MYSQL_USER}_
      " | sed -e 's/^        //' > docker-compose.yml

### Créer le service et le démarrer

    docker-compose up -d

### Consulter les journaux

    docker-compose logs

### Arrêter le service

    docker-compose stop

### Supprimer le service

    docker-compose rm -f
    docker volume rm wordpress_data wordpress_conf wordpress_html
    
