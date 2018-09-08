#  Cass

### Lectures

* [Docker](https://github.com/umiddelb/armhf/wiki/Get-Docker-up-and-running-on-the-RaspberryPi-(ARMv6)-in-four-steps-(Wheezy))
* [...](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/debian/#install-docker-ce-1)
* [...](https://hub.docker.com/u/arm32v7/)
* [SSL](https://www.shellhacks.com/openssl-check-ssl-certificate-expiration-date/)
* [IPv6](https://docs.docker.com/config/daemon/ipv6/)
*

## Changer la taille disque par defaut des conteneurs 'Docker' '20Go' => '60Go'

    cd ~/Library/Containers/com.docker.docker/Data/database
    mkdir -v com.docker.driver.amd64-linux/disk
    TAILLE=60
    echo $(expr ${TAILLE} \* 512)  > com.docker.driver.amd64-linux/disk/size
    cat com.docker.driver.amd64-linux/disk/size
    git add com.docker.driver.amd64-linux/disk/size
    git commit -s -m 'New target disk size'
    ##// sauvegarder les conteneurs
    #mv -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2 ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2.save
    #// supprimer les conteneurs : ATTENTION
    rm -v ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2


## Installer Docker sur une Raspberry Pi 3

### se reporter à [*Créer un NAS avec un disque externe USB*](NAS.md)

    #// passer 'root'
    sudo -i
        ##// ajouter la groupe 'docker' a l'utilisateur courant ('pi')
        #usermod -aG docker ${USER}
        #// creer le compte 'docker'
        COMPTE=docker
        ID=$(cat /etc/group|awk -F":"  "/^${COMPTE}/ {print \$3;}")
        DIR=/home/shares # (facultatif) voir NAS.md
        GROUPE=users # (facultatif) voir NAS.md
        adduser --disabled-login --disabled-password --home ${DIR}/${COMPTE} --uid ${ID} --ingroup ${COMPTE} ${COMPTE}; usermod -aG ${GROUPE} ${COMPTE}
        #// ajouter le depot 'edge'
        ARCH=armhf
        echo "deb [arch=${ARCH}] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable edge" | tee /etc/apt/sources.list.d/docker.list
        #mv -v /var/lib/docker/* /home/shares/docker/
        #ls -la /var/lib/docker/
        #rm -rv /var/lib/docker
        ln -s /home/shares/docker /var/lib/docker
        #ls -la /var/lib/docker/

        #// mettre en commentaire la ligne 'BUILD_EXCLUSIVE_KERNEL="^4.9.*"' dans le fichier '/usr/src/aufs-4.9+20161219/dkms.conf'
        sed -i -e "s/^\(BUILD_EXCLUSIVE_KERNEL=\"^4.9.*\"\)/# \1/g" /usr/src/aufs-4.9+20161219/dkms.conf

        #// mettre a jour et installer docker-ce
        apt-get update && sudo apt-get install docker-ce
        ##// ajouter $USER au groupe 'docker'
        systemctl enable docker.service
        // relancer
        service docker stop

        reboot

    #// passer 'docker'
        sudo -u docker -i
        #// verifier l'installation
        docker info
        docker version

        #// tester
        docker container run arm32v7/hello-world


## Installation de Nextcloud dans un conteneur Docker avec 'mount'

### Lectures

* [nextcloud](https://hub.docker.com/r/arm32v7/nextcloud/)
* [volume](https://docs.docker.com/storage/volumes/#start-a-container-with-a-volume)
* [bind](https://docs.docker.com/storage/bind-mounts/#start-a-container-with-a-bind-mount)
*


    http://10.0.1.121:1080/index.php/apps/files/?dir=/&fileid=7

    #// passer 'docker'
    sudo -u docker -i
        # creer la volume 'nextcloud-vol'
        docker volume create nextcloud-vol
        docker volume ls
        docker volume inspect nextcloud-vol
        docker container run -d \
        -it \
        --name nextcloud \
        --mount source=nextcloud-vol,target=/var/www \
        -p 1080:80 arm32v7/nextcloud

    ##// creer le repertoire nextcloud/www
    #    mkdir -pv nextcloud/www
    #    docker container run -d \
    #    -it \
    #    --name nextcloud \
    #    --mount type=bind,source="$(pwd)"/nextcloud/www,target=/var/www \
    #    -p 1080:80 arm32v7/nextcloud





## Installation de Cassandra avec SSL dans un conteneur Docker

### Lectures

* [Configuring Java CAPS for SSL Support](https://docs.oracle.com/cd/E19509-01/820-3503/jcapsconfssls_intro/index.html)
* [Datastax configuration SSL](https://docs.datastax.com/en/developer/cpp-driver/2.8/topics/security/ssl/)
*

### Création du conteneur Docker Cassandra avec SSL

    CONTENEUR=cassandra

    // installer le conteneur cassandra
    docker container run --name ${CONTENEUR} --privileged -p 7000:7000 -p7001:7001 -p7199:7199 -p9042:9042 -p9160:9160 cassandra:latest -d
    docker container logs ${CONTENEUR} > ${CONTENEUR}_install.log

    // entrer dans le conteneur
    docker container exec -t -i ${CONTENEUR} /bin/bash
        // Changements utiles pour les exemples autres que 'ssl'
        // sauvegarder la configuration
        cp -v /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.yaml.origin
        // autoriser les procedures stockees utilisateurs (facultatif)
        cat /etc/cassandra/cassandra.yaml|grep "^enable_user_defined_functions:"
        sed -i -e "s/^enable_user_defined_functions: false/enable_user_defined_functions: true #false/g" /etc/cassandra/cassandra.yaml
        cat /etc/cassandra/cassandra.yaml|grep "^enable_user_defined_functions:"
        // autoriser l'autentification par 'user/password' (facultatif)
        cat /etc/cassandra/cassandra.yaml|grep "^authenticator:"
        sed -i -e "s/^authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator #AllowAllAuthenticator/g" /etc/cassandra/cassandra.yaml
        cat /etc/cassandra/cassandra.yaml|grep "^authenticator:"
        // sortir du conteneur
        exit

    // arreter le conteneur
    docker stop ${CONTENEUR}

    CONTENEUR_SSL=cassandra_ssl

    // faire une copie du conteneur
    docker commit ${CONTENEUR} ${CONTENEUR_SSL}
    // lancer le nouveau conteneur SSL
    docker container run --name ${CONTENEUR_SSL} -p 7000:7000 -p7001:7001 -p7199:7199 -p9042:9042 -p9160:9160 ${CONTENEUR_SSL} -d
    docker container logs ${CONTENEUR_SSL} > ${CONTENEUR_SSL}_install.log

    // entrer dans le conteneur SSL
    docker container exec -t -i ${CONTENEUR_SSL} /bin/bash
        ALIAS=cassandra
        PASSWORD=cassandra
        CNAME=cassandra
        KEYSTORE=keystore.jks
        TRUSTSTORE=truststore.jks
        USER_ALIAS=driver
        USER_KEYSTORE=${USER_ALIAS}.jks
        USER_PASSWORD=password

        // creer le repertoire pour les magasins
        mkdir /etc/cassandra/conf
        // aller dans ce repertoire
        cd /etc/cassandra/conf
        // creer les cles serveur
        keytool -genkey -keyalg RSA -alias ${ALIAS} -validity 36500 -keystore ${KEYSTORE} -storepass ${PASSWORD} -keypass ${PASSWORD} -dname "CN=${CNAME}, OU=None, O=None, L=None, C=None"
        // creer le certificat serveur
        keytool -export -alias ${ALIAS} -file ${ALIAS}.cer -keystore ${KEYSTORE} -storepass ${PASSWORD}
        // faire confiance au serveur
        keytool -import -v -noprompt -trustcacerts -alias ${ALIAS} -file ${ALIAS}.cer -keystore ${TRUSTSTORE} -storepass ${PASSWORD}
        // creer les cles serveur au format PKCS12
        keytool -importkeystore -srckeystore ${KEYSTORE} -srcstorepass ${PASSWORD} -destkeystore ${ALIAS}.p12 -deststoretype PKCS12 -deststorepass ${PASSWORD}
        // certificat serveur seul
        openssl pkcs12 -in ${ALIAS}.p12 -nokeys -out ${ALIAS}.cer.pem -passin pass:${PASSWORD}
        // cle privee serveur seule
        openssl pkcs12 -in ${ALIAS}.p12 -nodes -nocerts -out ${ALIAS}.key.pem -passin pass:${PASSWORD}

        // creer les cles client
        keytool -genkey -keyalg RSA -alias ${USER_ALIAS} -validity 36500 -keystore ${USER_KEYSTORE} -storepass ${USER_PASSWORD} -keypass ${USER_PASSWORD} -dname "CN=${USER_ALIAS}, OU=None, O=None, L=None, C=None"
        // creer le certificat client
        keytool -export -alias ${USER_ALIAS} -file ${USER_ALIAS}.cer -keystore ${USER_KEYSTORE} -storepass ${USER_PASSWORD}
        // faire confiance au client
        keytool -import -v -noprompt -trustcacerts -alias ${USER_ALIAS} -file ${USER_ALIAS}.cer -keystore ${TRUSTSTORE} -storepass ${PASSWORD}
        // creer les cles client au format PKCS12
        keytool -importkeystore -srckeystore ${USER_KEYSTORE} -srcstorepass ${USER_PASSWORD} -destkeystore ${USER_ALIAS}.p12 -deststoretype PKCS12 -deststorepass ${USER_PASSWORD}
        // certificat client seul
        openssl pkcs12 -in ${USER_ALIAS}.p12 -nokeys -out ${USER_ALIAS}.cer.pem -passin pass:${USER_PASSWORD}
        // cle privee client seule
        openssl pkcs12 -in ${USER_ALIAS}.p12 -nodes -nocerts -out ${USER_ALIAS}.key.pem -passin pass:${USER_PASSWORD}

        // sortir du conteneur SSL
        exit

    // arreter le conteneur SSL
    docker stop ${CONTENEUR_SSL}
    // copier en local le fichier de configuration
    docker cp ${CONTENEUR_SSL}:/etc/cassandra/cassandra.yaml .

    ALIAS=cassandra
    USER_ALIAS=driver

    // copier en local les certificats et les cles necessaires pour l'exemple 'ssl'
    docker cp  /etc/cassandra/conf/${ALIAS}.cer.pem .
    docker cp  /etc/cassandra/conf/${USER_ALIAS}.cer.pem .
    docker cp  /etc/cassandra/conf/${USER_ALIAS}.key.pem .

    // modifier le fichier de configuration local
        ...
        authenticator: AllowAllAuthenticator
        ...
        # enable or disable client/server encryption.
        client_encryption_options:
        enabled: true #false
            # If enabled and optional is set to true encrypted and unencrypted connections are handled.
            optional: false
            keystore: /etc/cassandra/conf/keystore.jks #conf/.keystore
            keystore_password: cassandra
            require_client_auth: true #false
            # Set trustore and truststore_password if require_client_auth is true
            truststore: /etc/cassandra/conf/truststore.jks #conf/.truststore
            truststore_password: cassandra
            # More advanced defaults below:
            # protocol: TLS
            # algorithm: SunX509
            store_type: JKS
            # cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
        ...

    // recopier le fichier de configutation local dans le conteneur SSL
    docker cp cassandra.yaml ${CONTENEUR_SSL}:/etc/cassandra

    // redemarrer le conteneur SSL
    docker restart ${CONTENEUR_SSL}
