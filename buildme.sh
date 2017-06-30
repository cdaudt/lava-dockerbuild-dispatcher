TAGNAME="lava/dispatcher"
ATTEMPT=0
NOCACHE=${1:-true}
COPYTO=${2:-}
VER=${3:-"latest"}
ADMINUSER=lava-admin
PASSWORD=`cat /home/${ADMINUSER}/.pushpw`
LOGS=$(mktemp /tmp/buildme.XXXXXX)


function dockerpush()
{
  docker login -u ${ADMINUSER} -p ${PASSWORD} ${COPYTO}
  docker push $1
  docker logout ${COPYTO}
}

echo "NOCACHE:${NOCACHE} COPYTO:${COPYTO} VER=${VER} LOGS=${LOGS}"
if [ ! -d wiced-ocd ]
then
  echo "Missing wiced-ocd subdir. Checking it out"
  git clone git://git-iot.aus.cypress.com/wiced/hnd/lava/tools/wiced-ocd
fi
docker build \
  --label "build.source=`git log --oneline -1`" \
  --label "build.status=`git status --short`" \
  --no-cache=${NOCACHE} \
  -t lava/dispatcher:__stage0__ \
  . \
  >  ${LOGS} 2>&1
if [ $? -ne 0 ]
then
  cat ${LOGS}
  exit 1
fi

# Creation of LXC containers require --priviledged argument, which is only
# available to the docker run command (for now)
CIDFILE="cid.$RANDOM"
docker run -t --cidfile ${CIDFILE} --privileged lava/dispatcher:__stage0__ bin/bash -c "lxc-create -n cache-builder -t debian -- --release stretch --arch amd64 && lxc-destroy -n cache-builder -f" >> ${LOGS} 2>&1
RC=$?
read CID < ${CIDFILE}
rm ${CIDFILE}
if [ ${RC} -eq 0 ]
then
    docker commit ${CID} lava/dispatcher:__stage1__
fi
docker rm ${CID}
docker rmi lava/dispatcher:__stage0__
if [ ${RC} -ne 0 ]
then
  cat ${LOGS}
  exit 1
fi

docker build \
  --label "build.source=`git log --oneline -1`" \
  --label "build.status=`git status --short`" \
  --no-cache=${NOCACHE} \
  -t ${TAGNAME}:${VER} \
  -f Dockerfile-final \
  . \
  >>  ${LOGS} 2>&1
RC=$?
docker rmi lava/dispatcher:__stage1__
cat ${LOGS}
if [ ${RC} -ne 0 ]
then
  exit 1
fi
set -e
HASH=`tail ${LOGS}|grep "Successfully built "|awk '{print $3}'`
echo "IMAGE_BUILD:TAGNAME=${TAGNAME}:HASH=${HASH}"

if [ "${COPYTO}A" != "A" ]
then
  docker tag ${TAGNAME}:${VER} ${COPYTO}/${TAGNAME}:${VER}
  dockerpush ${COPYTO}/${TAGNAME}:${VER}
fi
