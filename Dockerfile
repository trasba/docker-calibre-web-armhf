FROM trasba/docker-baseimage-ubuntu-armhf

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="trasba"

RUN \
 echo "**** install runtime packages & dev packages ****" && \
 apt-get update && apt-get install -y \
        python \
        python-pip \
        python-setuptools \
        curl \
        file \
        libfontconfig1-dev \
        libfreetype6-dev \
        g++ \
        gcc \
        libgs-dev \
        liblcms2-dev \
        libturbojpeg0-dev \
        libpng-dev \
        libtool \
        libwebp-dev \
        libxml2-dev \
        libxslt1-dev \
        make \
        libperl-dev \
        python-dev \
        libtiff5-dev \
        zlib1g-dev && \
 echo "**** install calibre ****" && \
 apt-get install calibre --no-install-recommends -y && \
 echo "**** install calibre-web ****" && \
 mkdir -p /app/calibre-web && \
 curl -L https://github.com/trasba/calibre-web/archive/master.tar.gz \
        | tar xzv --strip-components=1 -C /app/calibre-web && \
 cd /app/calibre-web && \
 pip install --no-cache-dir -U -r requirements.txt && \
 sed -i 's/lxml==3.7.2/lxml>=3.8.0/g' optional-requirements.txt && \
 pip install --no-cache-dir -U -r optional-requirements.txt && \
 echo "**** cleanup ****" && \
 apt-get purge -y \
        file libfontconfig1-dev libfreetype6-dev g++ gcc libgs-dev \
        liblcms2-dev libturbojpeg0-dev libpng-dev libtool libwebp-dev \
        libxml2-dev libxslt1-dev make libperl-dev python-dev libtiff5-dev \
        zlib1g-dev python-dev autotools-dev binutils binutils-arm-linux-gnueabihf \
        binutils-common cpp cpp-7 dirmngr fakeroot fonts-droid-fallback \
        fonts-noto-mono g++-7 gcc-7 gcc-7-base gir1.2-harfbuzz-0.0 \
        gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client \
        gpg-wks-server gpgconf gpgsm icu-devtools libalgorithm-diff-perl \
        libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan4 \
        libassuan0 libatomic1 libbinutils libc-dev-bin libc6-dev libcc1-0 \
        libcilkrts5 libcupsfilters-dev libcupsfilters1 libcupsimage2 \
        libdpkg-perl libelf1 libexpat1-dev libfakeroot \
        libfile-fcntllock-perl libgcc-7-dev libgdbm-compat4 libgdbm5 \
        libglib2.0-bin libglib2.0-dev-bin libgraphite2-dev libgs9 \
        libgs9-common libharfbuzz-gobject0 libharfbuzz-icu0 libicu-le-hb0 \
        libiculx60 libijs-0.35 libijs-dev libijs-doc libisl19 libjbig-dev \
        libjbig2dec0 libjbig2dec0-dev libjpeg-dev libjpeg-turbo8-dev \
	libjpeg8-dev libksba8 liblocale-gettext-perl libltdl-dev \
        liblzma-dev libmagic-mgc libmagic1 libmpc3 libmpdec2 libmpfr6 \
        libnpth0 libpaper-dev libpaper-utils libpaper1 libpcre16-3 \
        libpcre3-dev libpcre32-3 libpcrecpp0v5 libperl5.26 libpng-tools \
        libpython-all-dev libpython-dev libpython2.7-dev libpython3-stdlib \
        libpython3.6-minimal libpython3.6-stdlib libstdc++-7-dev libtiffxx5 \
        libturbojpeg libubsan0 linux-libc-dev manpages manpages-dev netbase \
        patch perl perl-modules-5.26 pinentry-curses python-all \
        python2.7-dev python3 python3-distutils python3-lib2to3 \
        python3-minimal python3.6 && \
 apt-get clean && \
 rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8083
VOLUME /books /config
