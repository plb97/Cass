#  Cass


## Swift sur Raspberry Pi 3

### Lectures

* [Swift](https://github.com/apple/swift)
* 

### Récupérarion des sources et compilation

    sudo useradd -U -G sudo -m -s /bin/bash swift
    sudo -u swift -i
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev systemtap-sdt-dev tzdata rsync
    mkdir swift-source
    cd swift-source
    git clone https://github.com/apple/swift.git
    ./swift/utils/update-checkout --clone
    ./swift/utils/build-script --release-debuginfo --llvm-max-parallel-lto-link-jobs 1 --swift-tools-max-parallel-lto-link-jobs 1
