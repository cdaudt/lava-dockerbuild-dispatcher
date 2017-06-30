FROM lava/baseline

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get install -y \
 lava-dev

RUN pip install --pre -U pyocd

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

RUN \
 DEBIAN_FRONTEND=noninteractive apt-get -t jessie-backports install -y lxc
