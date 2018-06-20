FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

RUN apt-get update && apt-get install -y default-jdk curl
RUN curl http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz -o zookeeper-3.4.10.tar.gz
RUN tar -xzf zookeeper-3.4.10.tar.gz && cd zookeeper-3.4.10 && cp conf/zoo_sample.cfg conf/zoo.cfg
WORKDIR /zookeeper-3.4.10
CMD ["./bin/zkServer.sh", "start"]
