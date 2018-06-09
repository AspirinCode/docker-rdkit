#!/bin/bash

set -xe

source params.sh

# build RDKit
docker build -f Dockerfile-build-debian\
  -t $BASE/rdkit-build:$DOCKER_TAG\
  --build-arg GIT_BRANCH=$GIT_BRANCH\
  --build-arg GIT_TAG=$GIT_TAG .

# copy the packages
rm -rf artifacts/$DOCKER_TAG
mkdir -p artifacts/$DOCKER_TAG
mkdir artifacts/$DOCKER_TAG/debs
mkdir artifacts/$DOCKER_TAG/rpms
mkdir artifacts/$DOCKER_TAG/java
docker run -it --rm -u $(id -u)\
  -v $PWD/artifacts/$DOCKER_TAG:/tohere:Z\
  $BASE/rdkit-build:$DOCKER_TAG bash -c 'cp build/*.deb /tohere/debs && cp build/*.rpm /tohere/rpms && cp Code/JavaWrappers/gmwrapper/org.RDKit.jar /tohere/java && cp Code/JavaWrappers/gmwrapper/libGraphMolWrap.so /tohere/java'

# build image for python on debian
docker build -f Dockerfile-python-debian\
  -t $BASE/rdkit-python-debian:$DOCKER_TAG\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image informaticsmatters/rdkit-python-debian:$DOCKER_TAG"

# build image for python on centos
docker build -f Dockerfile-python-centos\
  -t $BASE/rdkit-python-centos:$DOCKER_TAG\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image informaticsmatters/rdkit-python-centos:$DOCKER_TAG"

# build image for java on debian
docker build -f Dockerfile-java-debian\
  -t $BASE/rdkit-java-debian:$DOCKER_TAG\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image informaticsmatters/rdkit-java-debian:$DOCKER_TAG"

# build image for tomcat on debian
docker build -f Dockerfile-tomcat-debian\
  -t $BASE/rdkit-tomcat-debian:$DOCKER_TAG\
  --build-arg DOCKER_TAG=$DOCKER_TAG .
echo "Built image informaticsmatters/rdkit-tomcat-debian:$DOCKER_TAG"

