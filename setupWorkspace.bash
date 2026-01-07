#!/bin/bash
#
# Package iobench and setup the workspace for execution on server.
# Additional command-line arguments are passed as extra Maven build switches. E.g. "-Dmaven.test.skip=true"
#
ROOT=$PWD
PP="$ROOT/photpipe"
WS="$ROOT/workspace"
PP_VERSION="22.3.0-SNAPSHOT"

echo "Building photpipe for ./workspace..."
pushd $PP
mvn clean package -Dmaven.test.skip=true -P Bundle "$@"
popd

mkdir -p $WS
rm -f $WS/*bundle.zip $WS/*.jar IngestSpark*.jar
rm -rf $WS/lib
cp $PP/Bundle/target/Bundle-22.3.0-SNAPSHOT-bundle.zip $WS/
cp $PP/./PhotPipeIngest/IngestSpark/target/IngestSpark-22.3.0-SNAPSHOT.jar $WS/

pushd $WS
unzip -j *bundle.zip -d ./lib
popd

echo "... done!"

