FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

RUN apt-get update && apt-get install -y curl gnupg
RUN apt-get purge cmdtest
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip libsasl2-dev libldap2-dev git libmysqlclient-dev nodejs curl yarn
RUN pip install --upgrade setuptools pip
RUN pip install cryptography
RUN pip install "PyAthenaJDBC>1.0.9" pymssql psycopg2 mysqlclient
RUN git clone git://github.com/SavvyPlus/incubator-superset /tmp/savvy-superset
WORKDIR /tmp/savvy-superset/superset/assets
RUN yarn
RUN yarn build
WORKDIR /tmp/savvy-superset
RUN pip install -e /tmp/savvy-superset

# superset configuration/setup
ADD superset_admin.config /tmp/superset_admin.config
RUN fabmanager create-admin --app superset < /tmp/superset_admin.config
RUN superset db upgrade && superset load_examples && superset init
EXPOSE 8088/tcp
CMD superset runserver -d
