#!/bin/bash
timestamp=$(date +%Y%m%d%H%M)
TEST=test-002
SPARK_APP_NAME=gbin-index-${TEST}-${timestamp}
export SPARK_CONF_DIR=/dpci/spark/conf/
SPARK_MASTER="spark://10.6.53.11:7077"

APP_HOME=`realpath $PWD`
WS_HOME=`dirname ${APP_HOME}`
LIB_HOME="$WS_HOME/lib"
EXEC_JAR="file://$WS_HOME/IngestSpark-22.3.0-SNAPSHOT.jar"
DRIVER_CLASS="gaia.cu5.phot.ingest.drivers.GbinToIndexedStore"
LOG4J_FILE="${WS_HOME}/log4j.properties"
LOG4J_OPTS="-Dlog4j.configuration=file://${LOG4J_FILE}"
JAVA17_EXTRA_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED"

# Define and create output directory.
OUTPUT_DIR="${APP_HOME}/output/${SPARK_APP_NAME}"
mkdir -p $OUTPUT_DIR

GBINS="/share/cyc5-consolidation-diops-1760/testruns/testdata/PhotoObservation-11"
CONF="${APP_HOME}/conf"

spark-submit\
  --master ${SPARK_MASTER}\
  --deploy-mode cluster\
  --name ${SPARK_APP_NAME}\
  --conf spark.driver.extraJavaOptions="\
    $LOG4J_OPTS\
    $JAVA17_EXTRA_OPTS"\
  --conf spark.executor.extraJavaOptions="\
    $LOG4J_OPTS\
    $JAVA17_EXTRA_OPTS"\
  --conf spark.driver.memory=10g\
  --conf spark.executor.memory=10g\
  --conf spark.executor.cores=1\
  --conf spark.cores.max=2000\
  --conf spark.kryoserializer.buffer.max=1g\
  --class gaia.dpci.echidna.app.AppLauncher\
  --jars file://`echo ${LIB_HOME}/* | sed 's/ /,file:\/\//g'`\
  ${EXEC_JAR}\
  gaia.dpci.spkl.app.DriverApp\
  -driver ${DRIVER_CLASS} \
  -models "CdbBindings" \
    -modules "\
gaia.dpci.charybdis.io.injection.CharybdisModule,\
gaia.dpci.echidna.core.injection.CoreModule,\
gaia.cu5.pipe.babel.MdbBabelModule,\
gaia.cu5.forge.mdb.runtime.inject.ForgeModule,\
gaia.cu5.forge.mdb.runtime.inject.ForgeMdbRuntimeModule,\
gaia.cu5.phot.ingest.injection.IngestSparkModule,\
gaia.cu5.pipe.gtlayer.gbin.GBinModule,\
gaia.cu5.phot.gbin.spark.input.GbinInputModule,\
gaia.cu5.du04.cdb.injection.CdbModule" \
  -inputs "\
gbins[0]=>file://${GBINS},
partition=>file://${CONF}/partitionConf.yaml,
parquet=>file://${CONF}/parquetConf.yaml,
stores.out=>file://${CONF}/outputConf.yaml"\
  -output "file://${OUTPUT_DIR}/"
