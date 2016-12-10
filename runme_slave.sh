VER="cypress-0"
export LAVA_MASTER=`ifconfig eth0 | grep "inet addr:"|cut -d: -f2|cut -d" " -f1`
docker run -it \
  -e LAVA_MASTER=$LAVA_MASTER \
  -v /boot:/boot \
  -v /lib/modules:/lib/modules \
  -v $PWD/fileshare:/opt/fileshare \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /home/csd/.ssh/id_rsa_lava.pub:/home/lava/.ssh/authorized_keys:ro \
  --device=/dev/ttyUSB1 \
  -p 9000:80 \
  -p 2023:22 \
  -h dispatcher3 \
  --privileged \
  lava-dispatcher

