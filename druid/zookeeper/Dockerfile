FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

RUN apt-get update && apt-get install -y default-jdk curl
RUN curl http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-3.4.10 /opt/zookeeper \
    && cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
WORKDIR /opt/zookeeper
EXPOSE 2181 2888 3888
ENTRYPOINT ["./bin/zkServer.sh", "start-foreground"]
