#!/bin/bash -eu

nodeType=$1

JAVA=java
if [ "$JAVA_HOME" != "" ]; then
  JAVA=$JAVA_HOME/bin/java
fi

echo $JAVA_HOME
ls -la /etc/druid/conf/_common
ls -la /etc/druid/conf/$nodeType
ls -la /opt/druid/lib
which java
java -version

java `cat /etc/druid/conf/$nodeType/jvm.config | xargs` -cp /etc/druid/conf/_common:/etc/druid/conf/$nodeType:/opt/druid/lib/* io.druid.cli.Main server $nodeType
