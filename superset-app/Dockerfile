FROM ubuntu:latest
MAINTAINER ykydxt@gmail.com
ARG VER=unknown

# superset configuration/setup
RUN ls /var/lib/docker/tmp/docker-builder435027835
RUN find . -name superset_admin.config
RUN ls -a
RUN ls /tmp
ADD superset_admin.config superset_admin.config
RUN export LC_ALL=C.UTF-8 && fabmanager create-admin --app superset < superset_admin.config
RUN export LC_ALL=C.UTF-8 && superset db upgrade && superset init
EXPOSE 8088/tcp
CMD gunicorn -w 10 -k gevent --timeout 300 -b 0.0.0.0:8088 --limit-request-line 0 --limit-request-field_size 0 superset:app

