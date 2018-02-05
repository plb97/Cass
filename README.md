#  Cass

Première tentative **expérimentale** pour utiliser avec le langage **Swift** (version 4) d'*Apple* la base NoSQL **Cassandra** (version 3) via le pilote **cpp-driver** (version 2.8) de *Datastax*

**Note: DataStax products do not support big-endian systems.**

## intallation du pilote

### informations
   [cpp-driver]( https://docs.datastax.com/en/developer/cpp-driver/)

### préparation
    git clone https://github.com/datastax/cpp-driver.git
    brew update
    brew upgrade
    brew install autoconf automake cmake libtool
    brew install libuv
    brew install openssl
    brew link --force openssl

### construction
    cd cpp-driver
    mkdir build
    pushd build
    cmake ..
    make
    sudo make install
    popd

