FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip libsasl2-dev libldap2-dev git
RUN pip install --upgrade setuptools pip
RUN pip install cryptography
RUN pip install git+git://github.com/SavvyPlus/incubator-superset

# superset configuration/setup
ADD superset_admin.config /tmp/superset_admin.config
RUN fabmanager create-admin --app superset < /tmp/superset_admin.config
RUN superset db upgrade && superset load_examples && superset init
EXPOSE 8088/tcp
CMD superset runserver -d
