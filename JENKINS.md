#  Cass

## Jenkins

### Lectures

* [proxy](https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy)
* 

        FROM openjdk:8-jdk-alpine

        RUN apk add --no-cache git openssh-client curl unzip bash ttf-dejavu coreutils tini

        ARG user=jenkins
        ARG group=jenkins
        ARG uid=1000
        ARG gid=1000
        ARG http_port=8080
        ARG agent_port=50000
        ARG JENKINS_HOME=/var/jenkins_home
        ARG REF=/usr/share/jenkins/ref

        ENV JENKINS_HOME $JENKINS_HOME
        ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
        ENV REF $REF

        # Jenkins is run with user `jenkins`, uid = 1000
        # If you bind mount a volume from the host or a data container,
        # ensure you use the same uid
        RUN mkdir -p $JENKINS_HOME \
          && chown ${uid}:${gid} $JENKINS_HOME \
          && addgroup -g ${gid} ${group} \
          && adduser -h "$JENKINS_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}

        # Jenkins home directory is a volume, so configuration and build history
        # can be persisted and survive image upgrades
        VOLUME $JENKINS_HOME

        # $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
        # to set on a fresh new installation. Use it to bundle additional plugins
        # or config file with your custom jenkins Docker image.
        RUN mkdir -p ${REF}/init.groovy.d

        # jenkins version being bundled in this docker image
        ARG JENKINS_VERSION
        ENV JENKINS_VERSION ${JENKINS_VERSION:-2.60.3}

        # jenkins.war checksum, download will be validated using it
        ARG JENKINS_SHA=2d71b8f87c8417f9303a73d52901a59678ee6c0eefcf7325efed6035ff39372a

        # Can be used to customize where jenkins.war get downloaded from
        ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

        # could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
        # see https://github.com/docker/docker/issues/8331
        RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
          && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

        ENV JENKINS_UC https://updates.jenkins.io
        ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
        ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
        RUN chown -R ${user} "$JENKINS_HOME" "$REF"

        # for main web interface:
        EXPOSE ${http_port}

        # will be used by attached slave agents:
        EXPOSE ${agent_port}

        ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

        USER ${user}

        COPY jenkins-support /usr/local/bin/jenkins-support
        COPY jenkins.sh /usr/local/bin/jenkins.sh
        COPY tini-shim.sh /bin/tini
        ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

        # from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup $REF/plugins from a support bundle
        COPY plugins.sh /usr/local/bin/plugins.sh
        COPY install-plugins.sh /usr/local/bin/install-plugins.sh


### Créer le fichier 'env.sh' 

    echo $'#!/bin/sh
        MAINTENER=plb97
        APPLI=$(basename $(pwd)) # jenkins
        VERS=latest
        TAG=alpine_${VERS}
        BASE=${MAINTENER}/openjdk8:${TAG}
        JENKINS_USER=jenkins
        JENKINS_HOME=/var/jenkins_home
        ' | sed -e 's/^        //' > env.sh
    chmod +x env.sh
    .  env.sh

### Céer le fichier 'jenkins'

    echo $'#!/bin/sh
        #
        # Startup script for the Jenkins Continuous Integration server
        # (via tini)
        #
        # chkconfig: - 85 15
        # description: tini jenkins
        # processname: jenkins
        ## pidfile: $JENKINS_HOME/jenkins.pid

        export JENKINS_USER=jenkins
        export JENKINS_HOME=/var/jenkins_home
        
        ## Set Tomcat environment.
        #LOCKFILE=/var/lock/jenkins
        #export PATH=/usr/local/bin:$PATH
        #export HOME=/var/jenkins_home
        #export JAVA_HOME=/usr/lib/jvm/java-6-sun
        #export JENKINS_BASEDIR=/home/jenkins
        #export TOMCAT_HOME=$JENKINS_BASEDIR/apache-tomcat-6.0.18
        #export CATALINA_PID=$JENKINS_BASEDIR/jenkins-tomcat.pid
        #export CATALINA_OPTS="-DJENKINS_HOME=$JENKINS_BASEDIR/jenkins-home -Xmx512m -Djava.awt.headless=true"

        # Source function library.
        . /etc/rc.d/init.d/functions

        #[ -f $TOMCAT_HOME/bin/catalina.sh ] || exit 0

        #export PATH=$PATH:/usr/bin:/usr/local/bin

        # See how we were called.
        case "$1" in
          start)
                # Start daemon.
                echo -n "Starting Tini: "
                su -p -s /bin/sh $JENKINS_USER -c "$TOMCAT_HOME/bin/catalina.sh start"
                RETVAL=$?
                echo
                [ $RETVAL = 0 ] && touch $LOCKFILE
                ;;
          stop)
                # Stop daemons.
                echo -n "Shutting down Tomcat: "
                su -p -s /bin/sh $JENKINS_USER -c "$TOMCAT_HOME/bin/catalina.sh stop"
                RETVAL=$?
                echo
                [ $RETVAL = 0 ] && rm -f $LOCKFILE
                ;;
          restart)
                $0 stop
                $0 start
                ;;
          condrestart)
               [ -e $LOCKFILE ] && $0 restart
               ;;
          status)
                status -p $CATALINA_PID -l $(basename $LOCKFILE) jenkins
                ;;
          *)
                echo "Usage: $0 {start|stop|restart|status}"
                exit 1
        esac

        exit 0
        ' | sed -e 's/^        //' > jenkins


### Creer le fichier 'Dockerfile'

    .  env.sh

    echo $'ARG BASE
        FROM ${BASE}
        
        RUN apk add --no-cache git openssh-client curl unzip bash ttf-dejavu coreutils tini
        
        ARG user=jenkins
        ARG group=jenkins
        ARG uid=1000
        ARG gid=1000
        ARG http_port=8080
        ARG agent_port=50000
        ARG JENKINS_HOME=/var/jenkins_home
        ARG REF=/usr/share/jenkins/ref
        
        ENV JENKINS_HOME $JENKINS_HOME
        ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
        ENV REF $REF
        
        # Jenkins is run with user `jenkins`, uid = 1000
        # If you bind mount a volume from the host or a data container,
        # ensure you use the same uid
        RUN mkdir -p $JENKINS_HOME \
          && chown ${uid}:${gid} $JENKINS_HOME \
          && addgroup -g ${gid} ${group} \
          && adduser -h "$JENKINS_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}
        
        # Jenkins home directory is a volume, so configuration and build history
        # can be persisted and survive image upgrades
        VOLUME $JENKINS_HOME
        
        # $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
        # to set on a fresh new installation. Use it to bundle additional plugins
        # or config file with your custom jenkins Docker image.
        RUN mkdir -p ${REF}/init.groovy.d
        
        # jenkins version being bundled in this docker image
        ARG JENKINS_VERSION
        ENV JENKINS_VERSION ${JENKINS_VERSION:-2.60.3}
        
        # jenkins.war checksum, download will be validated using it
        ARG JENKINS_SHA=2d71b8f87c8417f9303a73d52901a59678ee6c0eefcf7325efed6035ff39372a
        
        # Can be used to customize where jenkins.war get downloaded from
        ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war
        
        # could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
        # see https://github.com/docker/docker/issues/8331
        RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
          && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -
        
        ENV JENKINS_UC https://updates.jenkins.io
        ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
        ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
        RUN chown -R ${user} "$JENKINS_HOME" "$REF"
        
        # for main web interface:
        EXPOSE ${http_port}
        
        # will be used by attached slave agents:
        EXPOSE ${agent_port}
        
        ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
        
        RUN rc-update add jenkins default
        
        USER ${user}
        
        ##COPY jenkins-support /usr/local/bin/jenkins-support
        ##COPY jenkins.sh /usr/local/bin/jenkins.sh
        ##COPY tini-shim.sh /bin/tini
        ##ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
        
        ### from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup $REF/plugins from a support bundle
        ##COPY plugins.sh /usr/local/bin/plugins.sh
        ##COPY install-plugins.sh /usr/local/bin/install-plugins.sh
        
        ENTRYPOINT ["/sbin/openrc-init"]
        
        ' | sed -e 's/^        //' > Dockerfile

### Construire l'image

    .  env.sh

    docker image build --force-rm --no-cache --build-arg "BASE=${BASE}" -t "${MAINTENER}/${APPLI}:${TAG}" -t "${MAINTENER}/${APPLI}:latest" .

    docker image inspect "${MAINTENER}/${APPLI}:${TAG}"

### Lancer le conteneur

    .  env.sh

    docker container run --privileged --name ${APPLI}_${TAG} --init -p 8085:8080 -p 50005:50000 -d ${MAINTENER}/${APPLI}:${TAG}

### Utiliser le conteneur

    .  env.sh
    
    #// consulter le journal du conteneur
    docker container logs ${APPLI}_${TAG}

    #// Consulter les processus actifs
    docker container exec ${APPLI}_${TAG} ps

    #// aller dans le conteneur en tant que 'root'
    docker container exec -it ${APPLI}_${TAG} sh

    #// arreter le conteneur
    docker container stop ${APPLI}_${TAG}

    #// demarrer le conteneur
    docker container start ${APPLI}_${TAG}

    #// redemarrer le conteneur
    docker container restart ${APPLI}_${TAG}

### Nettoyer le conteneur

    .  env.sh
    
    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG}

### Nettoyer l'image
  
    .  env.sh

    docker container stop ${APPLI}_${TAG} ; \
    docker container rm ${APPLI}_${TAG} ; \
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
    for i in $(docker image ls -a|grep "<none>"|awk '{ print $3; }'); do echo $i;for c in $(dc ls -q -a -f "ancestor=$i"); do docker container rm --force $c; done; di rm $i; done

    docker image ls -a

