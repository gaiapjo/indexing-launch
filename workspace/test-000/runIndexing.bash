#!/bin/bash
timestamp=$(date +%Y%m%d%H%M)
TEST=test-000
SPARK_APP_NAME=gbin-index-${TEST}-${timestamp}
export SPARK_CONF_DIR=/dpci/spark/conf/
SPARK_MASTER="spark://10.6.53.11:7077"

APP_HOME=`realpath $PWD`
WS_HOME=`dirname ${APP_HOME}`
LIB_HOME="$WS_HOME/photpipe"
EXEC_JAR="file://$WS_HOME/IngestSpark-22.3.0-SNAPSHOT.jar"
DRIVER_CLASS="gaia.cu5.phot.ingest.drivers.GbinToIndexedStore"
LOG4J_FILE="${WS_HOME}/log4j.properties"
LOG4J_OPTS="-Dlog4j.configuration=file://${LOG4J_FILE}"
JAVA17_EXTRA_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED"

# Define and create output directory.
OUTPUT_DIR="${APP_HOME}/output/${SPARK_APP_NAME}"
mkdir -p $OUTPUT_DIR


