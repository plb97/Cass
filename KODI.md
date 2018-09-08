#  Cass

## Kodi

### Lectures

* [Kodi](https://www.youtube.com/watch?v=jJjUy3pfXgs)
* [TVHeadEnd](https://tvheadend.org/boards/5/topics/23499)
* 


### Installation TVHeadEnd

    mkdir kodi && cd kodi
    sudo apt-get -y install git cmake gettext libssl-dev libdvbcsa-dev
    sudo apt-get -y install debhelper libavahi-client-dev liburiparser-dev libpcre3-dev
    git clone https://github.com/tvheadend/tvheadend.git
    cd tvheadend
    AUTOBUILD_CONFIGURE_EXTRA=--disable-bintray_cache\ --disable-hdhomerun_static\ --disable-ffmpeg_static\ --disable-dvbscan ./Autobuild.sh
    cd ..
    sudo dpkg -i tvheadend_*_armhf.deb
    #./configure
    #make
    
    ##apt-get install -y software-properties-common
    ##apt-add-repository ppa:mamarley/tvheadend-git-stable
    
    
### Hauppauge

    #// firmware
    wget http://palosaari.fi/linux/v4l-dvb/firmware/Si2168/Si2168-B40/4.0.25/dvb-demod-si2168-b40-01.fw
    sudo mv -v dvb-demod-si2168-b40-01.fw /lib/firmware
    
    sudo apt-get -y install dtv-scan-tables dvb-tools lirc
    git clone https://git.code.sf.net/p/lirc-remotes/code lirc-remotes-code
    
    
    git clone http://git.linuxtv.org/cgit.cgi/v4l-utils.git
    cd v4l-utils
    ./bootstrap.sh
    ./configure
    make
    sudo make install
    
### iPad
    
#### Lectures

* [kodi](https://github.com/xbmc/xbmc/blob/master/docs/README.macOS.md)
* [IPTV](https://www.technadu.com/aragon-live-tv-kodi-addon/31796/)
* 
    
        cd /usr/local/bin
        sudo ln -s ../Cellar/gettext/*/bin/autopoint
        cd
        brew install swig
        cd kodi/tools/depends
        ./bootstrap
        ./configure --host=x86_64-apple-darwin --with-sdk=10.9
        ./configure --with-cpu=arm64 --with-sdk=10.9
        make -j$(getconf _NPROCESSORS_ONLN)
        cd ../..
        #make -j$(getconf _NPROCESSORS_ONLN) -C tools/depends/target/binary-addons
        /Users/Shared/xbmc-depends/buildtools-native/bin/cmake -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE=/Users/Shared/xbmc-depends/macosx10.9_x86_64-target/share/Toolchain.cmake ../kodi
        
        
