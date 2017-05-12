FROM debian:jessie-backports

# Add linaro staging repo
RUN apt-get clean && \
 apt-get update && \
 apt-get install -y wget

RUN cd /tmp && \
 wget http://images.validation.linaro.org/production-repo/production-repo.key.asc &&  \
 apt-key add production-repo.key.asc  && \
 echo "deb http://images.validation.linaro.org/production-repo sid main"  >>/etc/apt/sources.list.d/linaro.list

# Install debian packages used by the container
# Configure apache to run the lava server
# Log the hostname used during install for the slave name
RUN echo 'lava-server   lava-server/instance-name string lava-dispatch-3' | debconf-set-selections \
 && echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections \
 && echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections \
 && apt-get update

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get -t jessie-backports install -y \
 python-pyudev \
 ntp \
 kpartx \
 openbsd-inetd \
 python-sphinx \
 python3-sphinx \
 pep8 \
 python-setuptools \
 python-voluptuous \
 python-pip

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 python-setproctitle

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 lava-dev git

RUN pip install --pre -U pyocd

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 gdebi

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 tftpd-hpa

COPY lava-dispatcher_*deb /root


RUN \
 cd /root && \
 export DEBFILE=lava-dispatcher_*deb && \
 echo 'y'|DEBIAN_FRONTEND=noninteractive gdebi --option=APT::Get::force-yes=1,APT::Get::Assume-Yes=1 $DEBFILE && \
 rm ${DEBFILE}

RUN apt install -y lavapdu-client
RUN sed -i -e 's/^TFTP_DIRECTORY=.*$/TFTP_DIRECTORY="\/var\/lib\/lava\/dispatcher\/tmp"/' /etc/default/tftpd-hpa

COPY lava-slave /etc/lava-dispatcher/lava-slave
COPY wiced-ocd /opt/cyp_ocd
CMD \
  sed -i -e "s/{LAVA_MASTER}/$LAVA_MASTER/g" /etc/lava-dispatcher/lava-slave && \
  service lava-slave restart &&  \
  service tftpd-hpa restart && \
  sleep 5 && \
  tail -F /var/log/lava*/lava*log
