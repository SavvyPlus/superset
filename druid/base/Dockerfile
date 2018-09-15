FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

RUN apt-get update && apt-get install -y curl software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get install -y openjdk-8-jdk
RUN curl http://static.druid.io/artifacts/releases/druid-0.12.1-bin.tar.gz | tar -xzf - -C /opt \
    && mv /opt/druid-0.12.1 /opt/druid

ENV JAVA_HOME /usr/lib/jvm/openjdk-8
ADD base/run.sh /opt/druid/bin
ADD base/log4j2.xml /opt/druid/lib
ADD base/avatica-core-1.12.0.jar /opt/druid/lib
ADD base/wikiticker-index-new.json /opt/druid/quickstart

WORKDIR /opt/druid
RUN /opt/druid/bin/init
RUN chmod -R 777 /opt/druid/var
RUN chmod -R 777 /opt/druid/log
ENTRYPOINT bash
