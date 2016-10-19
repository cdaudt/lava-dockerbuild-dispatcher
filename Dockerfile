FROM debian:jessie-backports

RUN \
 echo 'lava-server   lava-server/instance-name string lava-slave-instance' | debconf-set-selections && \
 echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections && \
 echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
 apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -t jessie-backports -y lava-dispatcher lava-dev git python-pip && \
 pip install --pre -U pyocd && \
 cd /root && \
 git clone -b proj/add_wiced git://10.136.64.138/git/lava-dispatcher && \
 cd lava-dispatcher && \
 echo "cd \${DIR} && dpkg -i *.deb" >> /usr/share/lava-server/debian-dev-build.sh && \
 /usr/share/lava-server/debian-dev-build.sh -p lava-dispatcher && \
 rm -rf /var/lib/apt/lists/*

COPY lava-slave /etc/lava-dispatcher/lava-slave
COPY cyp_ocd /opt/cyp_ocd
CMD sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave && service lava-slave restart && bash
