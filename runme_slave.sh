export LAVA_MASTER=`host iot-docker-u01.aus.cypress.com|awk '{print $4}'`
docker run -it -e LAVA_MASTER=$LAVA_MASTER -v /boot:/boot -v /lib/modules:/lib/modules -v $PWD/fileshare:/opt/fileshare -v /dev/bus/usb:/dev/bus/usb -v /home/csd/.ssh/id_rsa_lava.pub:/home/lava/.ssh/authorized_keys:ro --device=/dev/ttyUSB1 -p 8001:80 -p 2023:22 -h lava-slave-002 --privileged lava-dispatcher

