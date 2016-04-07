FROM java:8-jdk
MAINTAINER Jan Moxter <jan.moxter@innobix.com>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r efaps && useradd -r -g efaps efaps
