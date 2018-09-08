#  Cass


## Postgres


    #// passer 'docker'
    sudo -u docker -i
        # creer la volume
        NAME=postgres
        VOLUME=${NAME}-vol
        docker volume create ${VOLUME}
        docker volume ls
        docker volume inspect ${VOLUME}
        DIR=/var/lib/postgresql/data
        POSTGRES_PASSWORD=... #// a definir
        PGDATA=${DIR}/pgdata
        docker container run -d \
        -it \
        -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        -e PGDATA=${PGDATA} \
        --name ${NAME} \
        --mount source=${VOLUME},target=${DIR} \
        --privileged \
        arm32v7/${NAME}
        
        docker container run -it --rm --link postgres:postgres arm32v7/postgres psql -h postgres -U postgres



