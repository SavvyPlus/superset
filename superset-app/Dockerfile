FROM ubuntu:latest
MAINTAINER foamdino@gmail.com
ARG VER=unknown

RUN apt-get update && apt-get install -y curl gnupg && apt-get purge cmdtest
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip libsasl2-dev libldap2-dev git libmysqlclient-dev nodejs curl yarn
RUN pip install --upgrade setuptools pip
RUN pip install cryptography gevent "PyAthenaJDBC>1.0.9" pymssql mysqlclient psycopg2 pydruid
RUN VER=${VERSION} git clone -b savvybi_staging --single-branch --depth=1 git://github.com/SavvyPlus/incubator-superset /tmp/savvy-superset && rm -rf /tmp/savvy-superset/.git
WORKDIR /tmp/savvy-superset/superset/assets
RUN yarn && yarn build
WORKDIR /tmp/savvy-superset
RUN pip install -e /tmp/savvy-superset

# superset configuration/setup
ADD superset_admin.config /tmp/superset_admin.config
RUN fabmanager create-admin --app superset < /tmp/superset_admin.config
RUN superset db upgrade && superset load_examples && superset init
EXPOSE 8088/tcp
CMD gunicorn -w 10 -k gevent --timeout 120 -b 0.0.0.0:8088 --limit-request-line 0 --limit-request-field_size 0 superset:app
