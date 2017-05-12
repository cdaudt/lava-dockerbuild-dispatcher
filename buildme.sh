TAGNAME="lava/dispatcher"
VER="latest"
ATTEMPT=0
NOCACHE=${1:-true}
COPYTO=${2:-}
ADMINUSER=lava-admin
PASSWORD=`cat /home/${ADMINUSER}/.pushpw`

function dockerpush()
{
  docker login -u ${ADMINUSER} -p ${PASSWORD} ${COPYTO}
  docker push $1
  docker logout ${COPYTO}
}

echo "NOCACHE:${NOCACHE} COPYTO:${COPYTO}"
if [ ! -d wiced-ocd ]
then
  echo "Missing wiced-ocd subdir. Checking it out"
  git clone git://git-iot.aus.cypress.com/wiced/hnd/lava/tools/wiced-ocd
fi
docker build \
  --label "build.source=`git log --oneline -1`" \
  --label "build.status=`git status --short`" \
  --no-cache=${NOCACHE} \
  -t ${TAGNAME}:${VER} \
  .
if [ $? -ne 0 ]
then
  exit 1
fi

if [ "${COPYTO}A" != "A" ]
then
  docker tag ${TAGNAME}:${VER} ${COPYTO}/${TAGNAME}:${VER}
  dockerpush ${COPYTO}/${TAGNAME}:${VER}
fi
