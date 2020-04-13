FROM lsiobase/ubuntu:bionic
#focal was not working unresolvable dependency issues 2020-04-13

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="trasba"

RUN \
echo "**** install dev packages ****" && \
       apt-get update && apt-get upgrade -y && apt-get install -y \
              #for gevent, greenlet, python-Levenshtein, python-ldap, flask-simpleldap
              gcc python-dev \
              #for python-ldap, flask-simpleldap
              libldap2-dev libsasl2-dev && \
#
echo "**** install calibre ****" && \
       apt-get install calibre --no-install-recommends -y && \
#
echo "**** install pip ****" && \
       curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
       python get-pip.py && \
       rm get-pip.py && \
#
echo "**** install calibre-web ****" && \
       mkdir -p /app/calibre-web && \
              curl -L https://github.com/janeczku/calibre-web/archive/0.6.6.tar.gz \
              | tar xzv --strip-components=1 -C /app/calibre-web && \
       cd /app/calibre-web && \
       pip install --no-cache-dir -U -r requirements.txt && \
       #for comicapi at least git necessary maybe check back later -> exclude for now
       sed -i 's/.*comicapi/#&/' optional-requirements.txt && \
       #not using -U as lxml, pillow builds fail -> falling back to already installed version currently lxml(4.2.1) Pillow(5.1.0)
       pip install --no-cache-dir -r optional-requirements.txt && \
#
echo "**** cleanup ****" && \
apt-get purge -y \
       binutils binutils-arm-linux-gnueabihf binutils-common cpp cpp-7 gcc gcc-7 gcc-7-base libasan4 libatomic1 libbinutils libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libgcc-7-dev libgomp1 libisl19 libldap2-dev libmpc3 libmpfr6 libsasl2-dev libubsan0 linux-libc-dev manpages manpages-dev libexpat1-dev libpython-dev libpython2.7-dev python-dev python2.7-dev && \
#
#need to reinstall calibre somehow it gets uninstalled -> fix this later
echo "**** reinstall calibre ****" && \
       apt-get install calibre --no-install-recommends -y && \
echo "**** continue cleanup ****" && \
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
