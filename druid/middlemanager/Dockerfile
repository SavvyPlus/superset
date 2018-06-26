FROM 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-base:0.1
MAINTAINER foamdino@gmail.com

ENTRYPOINT ["java","-server","-Xms64m","-Xmx64m","-Duser.timezone=UTC","-Dfile.encoding=UTF-8", \
"-Djava.io.tmpdir=var/tmp","-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager","-cp", \
"conf-quickstart/druid/_common:conf-quickstart/druid/middleManager:lib/*","io.druid.cli.Main","server","middleManager"]
