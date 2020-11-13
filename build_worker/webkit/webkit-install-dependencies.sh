#!/usr/bin/env bash

# On Linux systems, this script needs to be run with root rights.
if [ `uname` != "Darwin" ] && [ $UID -ne 0 ]; then
    sudo $0
    exit 0
fi

function printNotSupportedMessageAndExit() {
    echo
    echo "Currently this script only works for distributions supporting apt-get and yum."
    echo "Please add support for your distribution: http://webkit.org/b/110693"
    echo
    exit 1
}

function checkInstaller {
    # apt-get - Debian based distributions
    apt-get --version &> /dev/null
    if [ $? -eq 0 ]; then
        installDependenciesWithApt
        exit 0
    fi

    # dnf - Fedora
    dnf --version &> /dev/null
    if [ $? -eq 0 ]; then
        installDependenciesWithDnf
        exit 0
    fi

    # pacman - Arch Linux
    # pacman --version and pacman --help both return non-0
    pacman -Ss &> /dev/null
    if [ $? -eq 0 ]; then
        installDependenciesWithPacman
        exit 0
    fi

    if [ `uname` = "Darwin" ]; then
       installDependenciesWithBrew
       exit 0
    fi

    printNotSupportedMessageAndExit
}

function installDependenciesWithBrew {
    brew &> /dev/null
    if [ $? -gt 1 ]; then
        echo "Please install HomeBrew. Instructions on http://brew.sh"
        exit 1
    fi

    brew install autoconf \
         automake \
         cmake \
         enchant \
         gettext \
         gobject-introspection \
         intltool \
         itstool \
         libcroco \
         libgcrypt \
         libgpg-error \
         libtasn1 \
         libtiff \
         libtool \
         ninja \
         pango \
         pkg-config \
         sqlite \
         webp \
         xz
}

# If the package $1 is available, prints it. Otherwise prints $2.
# Useful for handling when a package is renamed on new versions of Debian/Ubuntu.
function aptIfElse {
    if apt-cache show $1 &>/dev/null; then
        echo $1
    else
        echo $2
    fi
}

function installDependenciesWithApt {
    # These are dependencies necessary for building WebKitGTK.
    packages=" \
        autoconf \
        automake \
        autopoint \
        autotools-dev \
        bubblewrap \
        cmake \
        gawk \
        geoclue-2.0 \
        gnome-common \
        gperf \
        gtk-doc-tools \
        intltool \
        itstool \
        libasound2-dev \
        libatk1.0-dev \
        libedit-dev \
        libenchant-dev \
        libevent-dev \
        libfaad-dev \
        libffi-dev \
        libfile-copy-recursive-perl \
        $(aptIfElse libgcrypt20-dev libgcrypt11-dev) \
        libgirepository1.0-dev \
        libgl1-mesa-dev \
        libgl1-mesa-glx \
        libgtk-3-dev \
        libgstreamer1.0-dev \
        libgstreamer-plugins-bad1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgudev-1.0-dev \
        libhyphen-dev \
        libjpeg-dev \
        libmount-dev \
        libmpg123-dev \
        libnotify-dev \
        libopenjp2-7-dev \
        libopus-dev \
        libpango1.0-dev \
        libpng-dev \
        libpulse-dev \
        librsvg2-dev \
        libseccomp-dev \
        libsecret-1-dev \
        libsoup2.4-dev \
        libsqlite3-dev \
        libsrtp2-dev \
        libsystemd-dev \
        libtasn1-6-dev \
        libtheora-dev \
        libtool \
        libvorbis-dev \
        libvpx-dev \
        libupower-glib-dev \
        libwebp-dev \
        libwoff-dev \
        libxcomposite-dev \
        libxt-dev \
        libxtst-dev \
        libxslt1-dev \
        libwayland-dev \
        ninja-build \
        patch \
        ruby \
        xfonts-utils"

    # These are dependencies necessary for running tests.
    packages="$packages \
        apache2 \
        curl \
        cups-daemon \
        dbus-x11 \
        gdb \
        fonts-liberation \
        hunspell \
        hunspell-en-us \
        hunspell-en-gb \
        libapache2-mod-bw \
        libapache2-mod-php \
        php-json \
        libcgi-pm-perl \
        libgpg-error-dev \
        psmisc \
        pulseaudio-utils \
        python-gi \
        python-psutil \
        python-yaml \
        ruby \
        ruby-json \
        ruby-highline \
        weston \
        xvfb"

    # These are dependencies necessary for building with the Flatpak SDK.
    # packages="$packages \
    #     flatpak"

    # These are dependencies necessary for building the jhbuild.
    packages="$packages \
        bison \
        flex \
        git \
        gobject-introspection \
        gsettings-desktop-schemas-dev \
        gyp \
        icon-naming-utils \
        libcroco3-dev \
        libcups2-dev \
        libdrm-dev \
        libegl1-mesa-dev \
        libepoxy-dev \
        libevdev-dev \
        libexpat1-dev \
        libfdk-aac-dev \
        libgbm-dev \
        libgles2-mesa-dev \
        libgnutls28-dev \
        libgpg-error-dev \
        libjson-glib-dev \
        libinput-dev \
        libmtdev-dev \
        liborc-0.4-dev \
        libp11-kit-dev \
        libpciaccess-dev \
        libproxy-dev \
        libpsl-dev \
        libssl-dev \
        libtiff5-dev \
        libunistring-dev \
        libv4l-dev \
        libxcb-composite0-dev \
        libxcb-xfixes0-dev \
        libxfont-dev \
        libxfont2 \
        libxkbfile-dev \
        libxkbcommon-x11-dev \
        libtool-bin \
        libudev-dev \
        libxml-libxml-perl \
        python-dev \
        python3-setuptools \
        ragel \
        uuid-dev \
        x11proto-bigreqs-dev \
        x11proto-composite-dev \
        x11proto-gl-dev \
        x11proto-input-dev \
        x11proto-randr-dev \
        x11proto-resource-dev \
        x11proto-scrnsaver-dev \
        x11proto-video-dev \
        x11proto-xcmisc-dev \
        x11proto-xf86dri-dev \
        xfonts-utils \
        xtrans-dev \
        xutils-dev \
        yasm"

    # These are dependencies necessary for using webkit-patch
    packages="$packages \
        git-svn \
        python3-secretstorage \
        subversion"

    # These are GStreamer plugins needed to play different media files.
    packages="$packages \
        gstreamer1.0-gl \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-pulseaudio"

    apt-get install -y $packages

    # Ubuntu Bionic doesn't ship pipenv. So fallback to the pip3 install path.
    if apt-cache show pipenv &>/dev/null; then
        apt-get install pipenv
    else
        apt-get install -y python3-pip
        pip3 install pipenv
    fi
}

function installDependenciesWithPacman {
    # These are dependencies necessary for building WebKitGTK.
    packages=" \
        alsa-lib \
        autoconf \
        automake \
        bubblewrap \
        cmake \
        libedit \
        libffi \
        file \
        findutils \
        gawk \
        gcc \
        gettext \
        gnome-common \
        gperf \
        grep \
        groff \
        gstreamer \
        gst-plugins-base-libs \
        gzip \
        hyphen \
        libevent \
        libtool \
        m4 \
        make \
        patch \
        pkg-config \
        sed \
        texinfo \
        util-linux \
        which \
        gtk-doc \
        intltool \
        itstool \
        atk \
        enchant \
        faad2 \
        geoclue2 \
        gobject-introspection \
        mesa \
        mesa-libgl \
        gtk3 \
        libsystemd \
        libjpeg-turbo \
        mpg123 \
        openjpeg2 \
        opus \
        pango \
        perl-file-copy-recursive \
        libgcrypt \
        libnotify \
        libpng \
        libpulse \
        librsvg \
        libseccomp \
        libsecret \
        libsoup \
        libsrtp \
        libsystemd \
        sqlite \
        libtasn1 \
        libtheora \
        libtool \
        libvorbis \
        libvpx \
        libwebp \
        libxcomposite \
        libxt \
        libxslt \
        libxtst \
        upower \
        ninja \
        ruby \
        util-linux \
        xorg-font-utils \
        wayland \
        woff2"

    # These are dependencies necessary for running tests.
    # Note: apache-mod_bw, ruby-json, and ruby-highline are available in the AUR
    packages="$packages \
        apache \
        curl \
        cups \
        gdb \
        hunspell \
        hunspell-en \
        hunspell-en_GB \
        php-apache \
        libgpg-error \
        psmisc \
        pulseaudio \
        python-gobject \
        python2-psutil \
        python2-yaml \
        ruby \
        ttf-liberation \
        weston \
        xorg-server-xvfb"

    # These are dependencies necessary for building with the Flatpak SDK.
    packages="$packages \
        flatpak \
        python-pipenv"

    # These are dependencies necessary for building the jhbuild.
    # Note: Could not find libegl-mesa
    packages="$packages \
        bison \
        expat \
        flex \
        git \
        gnutls \
        gobject-introspection \
        gsettings-desktop-schemas \
        gyp \
        icon-naming-utils \
        libcroco \
        libcups \
        libdrm \
        libepoxy \
        libevdev \
        libfdk-aac \
        libgpg-error \
        libinput \
        p11-kit \
        libpciaccess \
        libproxy \
        libpsl \
        libtiff \
        libunistring-dev \
        libxfixes \
        libxfont2 \
        libxcb \
        libxkbfile \
        libxkbcommon-x11 \
        mtdev \
        orc \
        perl-xml-libxml\
        python2 \
        python2-lxml \
        python-setuptools \
        ragel \
        bigreqsproto \
        compositeproto \
        glproto \
        inputproto \
        randrproto \
        resourceproto \
        scrnsaverproto \
        videoproto \
        xcmiscproto \
        xf86driproto \
        xorg-font-utils \
        xorg-util-macros \
        xtrans \
        yasm"

    # These are dependencies necessary for using webkit-patch
    packages="$packages \
        python-secretstorage \
        svn"

    # These are GStreamer plugins needed to play different media files.
    packages="$packages \
        gst-plugins-bad \
        gst-plugins-base \
        gst-plugins-good \
        gst-plugins-ugly"

    pacman -S --needed $packages

	cat <<-EOF

The following packages are available from AUR, and needed for running tests:

    apache-mod_bw ruby-json ruby-highline

Instructions on how to use the AUR can be found on the Arch Wiki:

    https://wiki.archlinux.org/index.php/Arch_User_Repository

You will also need to follow the instructions on the wiki to make 'python'
call python2 in the WebKit folder:

    https://wiki.archlinux.org/index.php/Python#Dealing_with_version_problem_in_build_scripts

Alternatively, you may use a Python 2.x virtualenv while hacking on WebKitGTK:

    https://wiki.archlinux.org/index.php/Python/Virtual_environment

EOF
}

function installDependenciesWithDnf {
    # These are dependencies necessary for building WebKitGTK.
    packages=" \
        atk-devel \
        alsa-lib-devel \
        autoconf \
        automake \
        bubblewrap \
        cairo-devel \
        cmake \
        enchant-devel \
        gcc-c++ \
        geoclue2-devel \
        gettext-devel \
        gobject-introspection-devel \
        gperf \
        gstreamer1-devel \
        gstreamer1-plugins-bad-free-devel \
        gstreamer1-plugins-base-devel \
        gtk-doc \
        gtk3-devel \
        hyphen-devel \
        intltool \
        json-glib-devel \
        libXt-devel \
        libXtst-devel \
        libxslt-devel \
        libedit-devel \
        libevent-devel \
        libffi-devel \
        libgcrypt-devel \
        libgudev1-devel \
        libjpeg-turbo-devel \
        libmount-devel \
        libnotify-devel \
        libpng-devel \
        libseccomp-devel \
        libsecret-devel \
        libsoup-devel \
        libsrtp-devel \
        libtasn1-devel \
        libtheora-devel \
        libv4l-devel \
        libvorbis-devel \
        libvpx-devel \
        libwebp-devel \
        libwayland-client-devel \
        libwayland-server-devel \
        mesa-libGL-devel \
        ninja-build \
        openjpeg2-devel \
        openssl-devel \
        opus-devel \
        patch \
        pcre-devel \
        perl-File-Copy-Recursive \
        perl-JSON-PP \
        perl-Switch \
        perl-Time-HiRes \
        perl-version \
        pulseaudio-libs-devel \
        python-devel \
        redhat-rpm-config \
        ruby \
        sqlite-devel \
        systemd-devel \
        upower-devel \
        woff2-devel"

    # These are dependencies necessary for running tests.
    packages="$packages \
        curl \
        cups \
        dbus-x11 \
        gdb \
        hunspell-en \
        hunspell-en-GB \
        httpd \
        liberation-fonts \
        libgpg-error-devel \
        mod_bw \
        mod_ssl \
        perl-CGI \
        php \
        php-json \
        psmisc \
        pulseaudio-utils \
        pygobject3-base \
        python2-psutil \
        python2-yaml \
        ruby \
        rubygem-json \
        rubygem-highline \
        weston-devel \
        xorg-x11-server-Xvfb"

    # These are dependencies necessary for building with the Flatpak SDK.
    packages="$packages \
        flatpak \
        pipenv"

    # These are dependencies necessary for building the jhbuild.
    packages="$packages \
        bison \
        cups-devel \
        docbook-utils \
        expat-devel \
        fdk-aac-devel \
        flex \
        git \
        gnutls-devel \
        gobject-introspection \
        gsettings-desktop-schemas-devel \
        gyp \
        icon-naming-utils \
        itstool \
        libXfont2-devel \
        libcroco-devel \
        libdrm-devel \
        libepoxy-devel \
        libevdev-devel
        libgpg-error-devel \
        libinput-devel \
        libp11-devel \
        libpciaccess-devel \
        libproxy-devel \
        libpsl-devel \
        libtiff-devel \
        libunistring-devel \
        libuuid-devel \
        libxcb-devel \
        libxkbfile-devel \
        libxkbcommon-x11-devel \
        mesa-libEGL-devel \
        mtdev-devel \
        orc-devel \
        perl-XML-LibXML \
        python3-setuptools \
        ragel \
        systemd-devel \
        xorg-x11-font-utils \
        xorg-x11-proto-devel \
        xorg-x11-util-macros \
        xorg-x11-xtrans-devel \
        yasm"

    # These are dependencies necessary for using webkit-patch
    packages="$packages
        git-svn \
        python3-secretstorage \
        subversion"

    # These are GStreamer plugins needed to play different media files.
    packages="$packages \
        gstreamer1-plugins-bad-free \
        gstreamer1-plugins-bad-free-extras \
        gstreamer1-plugins-base \
        gstreamer1-plugins-good \
        gstreamer1-plugins-good-extras \
        gstreamer1-plugins-ugly-free"

    dnf install $packages
}

checkInstaller

