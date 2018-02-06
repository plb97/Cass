#  Cass

## Notes

### Informations utiles

* [Markdown](https://learnxinyminutes.com/docs/fr-fr/markdown/)
* [Configuring Java CAPS for SSL Support](https://docs.oracle.com/cd/E19509-01/820-3503/jcapsconfssls_intro/index.html)
* [Datastax configuration SSL](https://docs.datastax.com/en/developer/cpp-driver/2.8/topics/security/ssl/)

### Création du conteneur Docker Cassandra avec SSL

    CONTENEUR=cassandra

    // installer le conteneur cassandra
    docker run --name ${CONTENEUR} -p 7000:7000 -p7001:7001 -p7199:7199 -p9042:9042 -p9160:9160 cassandra:latest -d
    docker logs ${CONTENEUR} > ${CONTENEUR}_install.log

    // entrer dans le conteneur
    docker exec -t -i ${CONTENEUR} /bin/bash
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
    // lancer le nouveau conteneur
    docker run --name ${CONTENEUR_SSL} -p 7000:7000 -p7001:7001 -p7199:7199 -p9042:9042 -p9160:9160 ${CONTENEUR_SSL} -d
    docker logs ${CONTENEUR_SSL} > ${CONTENEUR_SSL}_install.log

    // entrer dans le conteneur
    docker exec -t -i ${CONTENEUR_SSL} /bin/bash
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

        // sortir du conteneur
        exit

    // arreter le conteneur
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
            keystore: /etc/cassandra/conf/keystore.jks
            keystore_password: cassandra #conf/.keystore
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

    // recopier le fichier de configutation local dans le conteneur
    docker cp cassandra.yaml ${CONTENEUR_SSL}:/etc/cassandra

    // redemarrer le conteneur
    docker restart ${CONTENEUR_SSL}
