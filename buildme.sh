TAGNAME="lava/dispatcher"
VER="latest"
ATTEMPT=0
NOCACHE=${1:-true}
COPYTO=${2:-}
echo "NOCACHE:${NOCACHE} COPYTO:${COPYTO}"
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
  docker push ${COPYTO}/${TAGNAME}:${VER}
fi
