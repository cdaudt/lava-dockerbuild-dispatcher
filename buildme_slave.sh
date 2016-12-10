VER="cypress-0"
ATTEMPT=0
while :
do
	docker build $* -t lava/dispatcher:${VER} .
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

docker tag lava/dispatcher:${VER} rodan.ric.broadcom.com:5000/lava/dispatcher:${VER}
docker push rodan.ric.broadcom.com:5000/lava/dispatcher:${VER}
