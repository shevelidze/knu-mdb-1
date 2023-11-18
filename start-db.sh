#!/bin/sh

PASSWORD=mysecretpassword
SERVER_HOSTNAME=server
NETWORK=postgres-network

docker network create -d bridge $NETWORK > /dev/null
SERVER_CONTAINER_ID=$(docker run --rm --network $NETWORK -h $SERVER_HOSTNAME -e POSTGRES_PASSWORD=$PASSWORD -d postgres)
sleep 2
docker run -it --rm --network $NETWORK -e PGPASSWORD=$PASSWORD -v $(pwd):/app postgres psql -h $SERVER_HOSTNAME -U postgres

docker stop $SERVER_CONTAINER_ID > /dev/null
docker network rm $NETWORK > /dev/null
