TAGNAME="lava/dispatcher"
VER="cypress-1"
ATTEMPT=0
NOCACHE=${1:-false}
COPYTO=${2:-}
echo "NOCACHE:${NOCACHE} COPYTO:${COPYTO}"
while :
do
	docker build --no-cache=${NOCACHE} -t ${TAGNAME}:${VER} .
	if [ $? -eq 0 ]
	then 
		break
	fi
	ATTEMPT=`expr $ATTEMPT + 1`
	echo "Finished attempt ${ATTEMPT} unsuccessfully. Retrying"
	date
	echo =======================================================================================
	sleep 10m
done

if [ "${COPYTO}A" != "A" ]
then
	docker tag ${TAGNAME}:${VER} ${COPYTO}/${TAGNAME}:${VER}
	docker push ${COPYTO}/${TAGNAME}:${VER}
fi
