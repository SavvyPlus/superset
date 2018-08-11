FROM 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-base:0.1
MAINTAINER foamdino@gmail.com

EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 8091
EXPOSE 3306
EXPOSE 2181 2888 3888
EXPOSE 8100 8101 8102 8103 8104

WORKDIR /opt/druid
ENTRYPOINT cd /opt/druid && /opt/druid/bin/run.sh coordinator
