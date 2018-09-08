#  Cass

## Création d'une image 'Docker' pour Raspberry Pi 3 : Cassandra2 basée sur Alpine

### Lectures

* [Cassandra 2.2](https://docs.genesys.com/Documentation/OS/8.1.4/Cassandra/CasStep?action=pdfbook&title=Documentation:OS:Cassandra:CasStep:8.1.4)
* 

### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # cassandra2
        VERS=3.8
        TAG=alpine_${VERS}
        BASE=plb97/openjdk7:${TAG}
        CASS_VERS=2.2.13
        CASS_STORAGE_PORT=7000
        CASS_SSL_STORAGE_PORT=7001
        CASS_NATIVE_TRANSPORT_PORT=9042
        CASS_SSL_NATIVE_TRANSPORT_PORT=9142
        CASS_JMX_PORT=7199
        CASS_HOME_DIR=/home/cassandra
        CASS_DATA_DIR=${CASS_HOME_DIR}/data
        CASS_CONF_DIR=${CASS_HOME_DIR}/conf
        CASS_DATA_VOL=${CASS_DATA_DIR//\//-}
        CASS_CONF_VOL=${CASS_CONF_DIR//\//-}
        
        HOST_IP="$(ifconfig en0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        #HOST_IP="$(ip -4 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        HOST_IP6="$(ifconfig en0 2>/dev/null|grep \'\sinet6\s\'|awk \'{ print $2; }\')"
        #HOST_IP6="$(ip -6 a show en0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #HOST_IPW="$(ifconfig wlan0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        ##HOST_IPW="$(ip -4 a show wlan0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #HOST_IPW6="$(ifconfig wlan0 2>/dev/null|grep \'\sinet6\s\'|awk \'{ print $2; }\')"
        ##HOST_IPW6="$(ip -6 a show wlan0 2>/dev/null|grep inet|awk \'{ print $2; }\'|awk -F/ \'{ print $1; }\')"
        #DOCKER_HOST_IP="$(ifconfig docker0 2>/dev/null|grep \'\sinet\s\'|awk \'{ print $2; }\')"
        ##DOCKER_HOST_IP="$(ip -4 a show docker0 2>/dev/null|grep inet|awk \'1==NR { print $2; }\'|awk -F/ \'{ print $1; }\')"

        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        ARG CASS_VERS=2.2.13
        
        ENV CASS_VERS=${CASS_VERS} \\
            CASS_STORAGE_PORT=7000 \\
            CASS_SSL_STORAGE_PORT=7001 \\
            CASS_NATIVE_TRANSPORT_PORT=9042 \\
            CASS_SSL_NATIVE_TRANSPORT_PORT=9142 \\
            CASS_JMX_PORT=7199 \\
            CASS_HOME_DIR=/home/cassandra \\
            CASS_DATA_DIR=/home/cassandra/data \\
            CASS_CONF_DIR=/home/cassandra/conf \\
            CASSANDRA=apache-cassandra-${CASS_VERS} \\
            LANG=C.UTF-8
        
        RUN set -ex ; \\
            ##
            ## Installation de Cassandra
            ##
            cat /etc/hosts ; \\
            apk --no-cache add python2 ; \\
            addgroup -S cassandra ; \\
            echo CASS_HOME_DIR=${CASS_HOME_DIR} ; \\
            adduser -h ${CASS_HOME_DIR} -s /bin/sh -S -D -G cassandra cassandra ; \\
            mkdir -pv ${CASS_DATA_DIR} ${CASS_HOME_DIR}/logs ${CASS_HOME_DIR}/run ; \\
            cd /root ; \\
            wget http://mirrors.standaloneinstaller.com/apache/cassandra/${CASS_VERS}/${CASSANDRA}-bin.tar.gz ; \\
            tar zxf ${CASSANDRA}-bin.tar.gz ; \\
            rm -v ${CASSANDRA}-bin.tar.gz ; \\
            mv ${CASSANDRA}/* ${CASS_HOME_DIR} ; \\
            rm -rv ${CASSANDRA} ; \\
            ##
            ## Configuration Cassandra
            ##
            cass_conf=${CASS_CONF_DIR}/cassandra.yaml ; \\
            cp -v ${cass_conf} ${cass_conf}.origin ; \\
            grep -v \'\(^\s*#.*$\|^\s*$\)\' ${cass_conf}.origin > ${cass_conf}.config ; \\
            ##
            ### autoriser les procedures stockees utilisateurs (facultatif)
            grep "^enable_user_defined_functions:" ${cass_conf}.config ; \\
            sed -i -e "s/^enable_user_defined_functions: /enable_user_defined_functions: true #/g" ${cass_conf}.config ; \\
            grep "^enable_user_defined_functions:" ${cass_conf}.config ; \\
            ##
            ### autoriser l\'autentification par \'user/password\' (facultatif)
            grep "^authenticator:" ${cass_conf}.config ; \\
            sed -i -e "s/^authenticator: /authenticator: PasswordAuthenticator #/g" ${cass_conf}.config ; \\
            grep "^authenticator:" ${cass_conf}.config ; \\
            unset cass_conf ; \\
            ##
            ## Configuration Java
            ##
            #cass_opts=${CASS_CONF_DIR}/jvm.options ; \\
            ### restaurer la configuration d\'origine
            ##cp -v ${cass_opts} ${cass_opts}.origin ; \\
            #### changer le parametre de memoire de la JVM (#-Xms4G)
            ##grep "^#\\?-Xms.\+" ${cass_opts}
            ##sed -i -e "s/^#\\?-Xms.\+/-Xms500M/g" ${cass_opts}
            ##grep "^#\\?-Xms.\+" ${cass_opts}
            ##### changer le parametre de memoire de la JVM (#-Xmx4G)
            ##grep "^#\\?-Xmx.\+" ${cass_opts}
            ##sed -i -e "s/^#\\?-Xmx.\+/-Xmx500M/g" ${cass_opts}
            ##grep "^#\\?-Xmx.\+" ${cass_opts}
            #### changer le parametre de memoire de la JVM (#-Xmn800M)
            ##grep "^#\\?-Xmn.\+" ${cass_opts}
            ##sed -i -e "s/^#\\?-Xmn.\+/-Xmn200M/g" ${cass_opts}
            ##grep "^#\\?-Xmn.\+" ${cass_opts}
            ##unset cass_opts ; \\
            ##
            ## changer le proprietaire des fichiers Cassandra
            chown -R cassandra:cassandra ${CASS_HOME_DIR} ; \\
            ##
            ## Creation du scripte du service Cassandra
            ##
            cass_script=/etc/init.d/cassandra ; \\
            cass_conf=${CASS_CONF_DIR}/cassandra.yaml ; \\
            echo "#!/sbin/openrc-run" >> ${cass_script} ; \\
            echo "# ${cass_script}" >> ${cass_script} ; \\
            echo "" >> ${cass_script} ; \\
            echo "description=\\\"NoSQL database Cassandra.\\\"" >> ${cass_script} ; \\
            echo "" >> ${cass_script} ; \\
            echo "start() {" >> ${cass_script} ; \\
            echo "    ebegin \\\"Starting Cassandra\\\"" >> ${cass_script} ; \\
            echo "    ### changer l\'IP de \'rpc_address\'" >> ${cass_script} ; \\
            echo "    sed -e \\\"s/^rpc_address: /rpc_address: \$(hostname -i) #/g\\\" ${cass_conf}.config > ${cass_conf}" >> ${cass_script} ; \\
            echo "    #sed -e \\\"s/^listen_address: /listen_address: \$(hostname -i) #/g\\\" ${cass_conf}.config > ${cass_conf}" >> ${cass_script} ; \\
            echo "    #sed -e \\\"s/^          - seeds: /          - seeds: \$(hostname -i) #/g\\\" ${cass_conf}.config > ${cass_conf}" >> ${cass_script} ; \\
            echo "    pid_f=${CASS_HOME_DIR}/run/cassandra.pid" >> ${cass_script} ; \\
            echo "    error_log_f=${CASS_HOME_DIR}/logs/error.log" >> ${cass_script} ; \\
            echo "    heap_dump_f=$CASS_HOME_DIR/java_\$(date +%s).hprof" >> ${cass_script} ; \\
            echo "    start-stop-daemon -S -u cassandra -x ${CASS_HOME_DIR}/bin/cassandra -q -p \${pid_f} -t > ${CASS_HOME_DIR}/logs/cassandra.log || return 1" >> ${cass_script} ; \\
            echo "    start-stop-daemon -S -u cassandra -x ${CASS_HOME_DIR}/bin/cassandra -b -p \${pid_f} -- -p \${pid_f} -H \${heap_dump_f} -E \${error_log_f} > ${CASS_HOME_DIR}/logs/cassandra.log || return 2" >> ${cass_script} ; \\
            echo "    eend \$?" >> ${cass_script} ; \\
            echo "}" >> ${cass_script} ; \\
            echo "" >> ${cass_script} ; \\
            echo "stop() {" >> ${cass_script} ; \\
            echo "    ebegin \\\"Stopping Cassandra\\\"" >> ${cass_script} ; \\
            echo "    pid_f=\"${CASS_HOME_DIR}/run/cassandra.pid\"" >> ${cass_script} ; \\
            echo "    start-stop-daemon -K -p \${pid_f} -R TERM/30/KILL/5 >/dev/null" >> ${cass_script} ; \\
            echo "    RET=\$?" >> ${cass_script} ; \\
            echo "    rm -f \${pid_f}" >> ${cass_script} ; \\
            echo "    eend \$RET" >> ${cass_script} ; \\
            echo "    return \$RET" >> ${cass_script} ; \\
            echo "}" >> ${cass_script} ; \\
            echo "" >> ${cass_script} ; \\
            echo "reload() {" >> ${cass_script} ; \\
            echo "    ebegin \\\"Restarting Cassandra\\\"" >> ${cass_script} ; \\
            echo "    stop" >> ${cass_script} ; \\
            echo "    case "$?" in" >> ${cass_script} ; \\
            echo "        0|1)" >> ${cass_script} ; \\
            echo "            start" >> ${cass_script} ; \\
            echo "            case "$?" in" >> ${cass_script} ; \\
            echo "                0) eend 0 ;;" >> ${cass_script} ; \\
            echo "                1) eend 1 ;; # Old process is still running" >> ${cass_script} ; \\
            echo "                *) eend 1 ;; # Failed to start" >> ${cass_script} ; \\
            echo "            esac" >> ${cass_script} ; \\
            echo "            ;;" >> ${cass_script} ; \\
            echo "        *)" >> ${cass_script} ; \\
            echo "            # Failed to stop" >> ${cass_script} ; \\
            echo "            eend  1" >> ${cass_script} ; \\
            echo "            ;;" >> ${cass_script} ; \\
            echo "    esac" >> ${cass_script} ; \\
            echo "}" >> ${cass_script} ; \\
            chmod +x ${cass_script} ; \\
            rc-update add $(basename ${cass_script}) default ; \\
            unset cass_script cass_conf ; \\
            echo
        
        ENV PATH=${CASS_HOME_DIR}/bin:${PATH}
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        VOLUME ${CASS_DATA_DIR}
        VOLUME ${CASS_CONF_DIR}
        EXPOSE ${CASS_STORAGE_PORT}
        EXPOSE ${CASS_SSL_STORAGE_PORT}
        EXPOSE ${CASS_NATIVE_TRANSPORT_PORT}
        EXPOSE ${CASS_SSL_NATIVE_TRANSPORT_PORT}
        EXPOSE ${CASS_JMX_PORT}

        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --force-rm --no-cache --build-arg "BASE=${BASE}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Créer les volumes

    docker volume create ${APPLI}${CASS_DATA_VOL} ; docker volume create ${APPLI}${CASS_CONF_VOL}

### Lancer le conteneur

    .  env.sh

    docker volume create ${APPLI}${CASS_DATA_VOL} ; \
    docker volume create ${APPLI}${CASS_CONF_VOL} ; \
    docker container run --privileged --name ${APPLI}_${TAG} \
        -v ${APPLI}${CASS_DATA_VOL}:${CASS_DATA_DIR} \
        -v ${APPLI}${CASS_CONF_VOL}:${CASS_CONF_DIR} \
        -p ${CASS_STORAGE_PORT}:7000 \
        -p ${CASS_SSL_STORAGE_PORT}:7001 \
        -p ${CASS_NATIVE_TRANSPORT_PORT}:9042 \
        -p ${CASS_SSL_NATIVE_TRANSPORT_PORT}:9142 \
        -p ${CASS_JMX_PORT}:7199 \
        -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps
    
    #// Consulter les journaux
    docker container exec ${APPLI}_${TAG} cat ${CASS_HOME_DIR}/logs/system.log
    docker container exec ${APPLI}_${TAG} cat ${CASS_HOME_DIR}/logs/debug.log

    #// Verifier le demarrage de Cassandra
    docker container exec ${APPLI}_${TAG} tail -n 20 ${CASS_HOME_DIR}/logs/cassandra.log
    docker container exec ${APPLI}_${TAG} netstat -l|grep '^tcp.*:\(9042\|7199\).*LISTEN\s*$'
    # 0=oui, 1=non
    docker container exec ${APPLI}_${TAG} netstat -l|grep '^tcp.*:9042.*LISTEN\s*$' > /dev/null; echo $?

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it ${APPLI}_${TAG} sh

    #// utiliser une commande 'cqlsh'
    CQLSH="cqlsh --connect-timeout=30 -u cassandra -p cassandra ${HOST_IP}"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "describe keyspaces"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "CREATE KEYSPACE test WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3};"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "describe keyspace test"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "CREATE TABLE test.essai ( cle text PRIMARY KEY, texte text );"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "describe table test.essai"
    docker container exec -u cassandra ${APPLI}_${TAG} ${CQLSH} -e "DROP KEYSPACE test;"

    #// arreter le conteneur
    docker container stop ${APPLI}_${TAG}

    #// demarrer le conteneur
    docker container start ${APPLI}_${TAG}

    #// redemarrer le conteneur
    docker container restart ${APPLI}_${TAG}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${CASS_DATA_VOL} ; \
    docker volume rm ${APPLI}${CASS_CONF_VOL}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
    docker volume rm ${APPLI}${CASS_DATA_VOL} ; \
    docker volume rm ${APPLI}${CASS_CONF_VOL} ; \
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest

### Nettoyer les images
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; docker container rm ${APPLI}_${TAG}
    docker image ls -a
    docker image save -o ${APPLI}.tar ${MAINTENER}/${APPLI}:${TAG}
    docker image rm ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    docker image load -i ${APPLI}.tar ; docker image tag ${MAINTENER}/${APPLI}:${TAG} ${MAINTENER}/${APPLI}:latest
    rm -v ${APPLI}.tar
    docker image ls -a

    #// supprimer les images intermediaires restantes (facultatif)
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm $c; done; di rm $i; done

    docker image ls -a

