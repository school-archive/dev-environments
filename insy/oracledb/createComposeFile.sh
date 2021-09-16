which docker

echo "Which OracleDB version do you want to run?"
cd ./docker-images/OracleDatabase/SingleInstance/dockerfiles && \
echo "(  $(for i in */; do echo -n "${i%%/}  "; done))"

read;

VERSION="${REPLY}"

if [[ ! -d "$VERSION/" ]]
then
	echo "This version does not exist!" >&2
	exit 1
fi

echo "Please select a server edition"
echo -n "(Enterprise (e), Standard (s), Express (x)): "

read;
EDITION="${REPLY}"

if [[ ! "esx" =~ "$EDITION" ]]
then
	echo "Invalid argument!" >&2
	exit 1
fi


echo "Generating image using the buildContainerImage script..."
echo buildContainerImage.sh -v $VERSION -$EDITION
bash buildContainerImage.sh -v $VERSION -$EDITION

cd ../../../../

EDITION=$EDITION"e"

read -r -d '' composefile <<EOF
version: '3'
services:
  oracledb:
    image: oracle/database:$VERSION-$EDITION
    ports:
     - '1521:1521'
    restart: always
    volumes:
     - ./oradata:/opt/oracle/oradata
EOF

echo "$composefile" > docker-compose.yml

echo "Starting the container now..."

docker-compose up -d