#!/bin/bash
#
# Package iobench and setup the workspace for execution on server.
# Additional command-line arguments are passed as extra Maven build switches. E.g. "-Dmaven.test.skip=true"
#
ROOT=$PWD
PP="$ROOT/photpipe"
WS="$ROOT/workspace"
PP_VERSION="22.3.0-SNAPSHOT"

echo "Building PhotPipe..."
pushd $PP
mvn clean package -Dmaven.test.skip=true -P Bundle "$@"
popd

echo "Configuring workspace..."
mkdir -p $WS
rm -f $WS/*bundle.zip $WS/*.jar IngestSpark*.jar
rm -rf $WS/lib
cp $PP/Bundle/target/Bundle-${PP_VERSION}-bundle.zip $WS/

pushd $WS
unzip -j *bundle.zip -d ./lib
mv ./lib/IngestSpark-${PP_VERSION}.jar ./
popd

echo "... done!"

