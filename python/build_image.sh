#!/bin/bash

CURR_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO="phidata"
NAME="python"
TAG="3.9.2"

docker build -t $REPO/$NAME:$TAG $CURR_SCRIPT_DIR
docker push $REPO/$NAME:$TAG