FROM ubuntu:latest
MAINTAINER ykydxt@gmail.com
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
RUN VER=${VERSION} git clone -b SavvyBI_S --single-branch --depth=1 git://github.com/SavvyPlus/incubator-superset /tmp/savvy-superset && rm -rf /tmp/savvy-superset/.git
WORKDIR /tmp/savvy-superset/superset/assets
RUN yarn && yarn build
WORKDIR /tmp/savvy-superset
RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements-dev.txt
RUN pip3 install -e /tmp/savvy-superset

# Install Java
RUN  apt-get update && \
  yes | apt-get install default-jre && \
  yes | apt-get install default-jdk && \
  yes | apt-get install openjdk-11-jdk

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/bin/

#Samba JDBC Driver Installation
RUN mkdir -p /tmp/simba-driver
WORKDIR /tmp/simba-driver
RUN apt-get install wget
RUN wget https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.5/AthenaJDBC42_2.0.5.jar
ENV CLASSPATH /tmp/simba-driver

# superset configuration/setup
ADD superset-app/superset_admin.config /tmp/superset_admin.config
RUN export LC_ALL=C.UTF-8 && fabmanager create-admin --app superset < /tmp/superset_admin.config
RUN export LC_ALL=C.UTF-8 && superset db upgrade && superset init
RUN export FLASK_ENV=development
RUN echo 1->/app/logs/gunicorn.log
EXPOSE 8088/tcp
CMD gunicorn -w 10 -k gevent --log-level debug --timeout 300 -b 0.0.0.0:8088 --limit-request-line 0 --limit-request-field_size 0 --log-file /app/logs/gunicorn.log  superset:app