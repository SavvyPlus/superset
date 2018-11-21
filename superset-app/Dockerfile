FROM ubuntu:latest
MAINTAINER foamdino@gmail.com
ARG VER=unknown

RUN apt-get update && apt-get install -y curl gnupg && apt-get purge cmdtest
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev libldap2-dev git libmysqlclient-dev nodejs curl yarn \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python

RUN pip3 install --upgrade setuptools pip
RUN pip3 install gevent "PyAthenaJDBC>=2.0.0" "PyAthenaJDBC[SQLAlchemy]>1.0.9" pymssql mysqlclient psycopg2-binary


# remove any previously installed version of click
RUN pip3 uninstall click
RUN VER=${VERSION} git clone -b SavvyBI_Staging --single-branch --depth=1 git://github.com/SavvyPlus/incubator-superset /tmp/savvy-superset && rm -rf /tmp/savvy-superset/.git
WORKDIR /tmp/savvy-superset/superset/assets
RUN yarn && yarn build
WORKDIR /tmp/savvy-superset
RUN pip3 install -e /tmp/savvy-superset

# Install Java
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle

RUN apt-get update && \
  apt-get install -y --no-install-recommends locales && \
  locale-gen en_US.UTF-8 && \
  apt-get dist-upgrade -y && \
  apt-get --purge remove openjdk* && \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
  apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default && \
  apt-get clean all

#Samba JDBC Driver Installation
RUN mkdir -p /tmp/simba-driver
WORKDIR /tmp/simba-driver
RUN apt-get install wget
RUN wget https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.5/AthenaJDBC42_2.0.5.jar
ENV CLASSPATH /tmp/simba-driver

# superset configuration/setup
ADD superset_admin.config /tmp/superset_admin.config
RUN export LC_ALL=C.UTF-8 && fabmanager create-admin --app superset < /tmp/superset_admin.config
RUN export LC_ALL=C.UTF-8 && superset db upgrade && superset load_examples && superset init
EXPOSE 8088/tcp
CMD gunicorn -w 10 -k gevent --timeout 300 -b 0.0.0.0:8088 --limit-request-line 0 --limit-request-field_size 0 superset:app
