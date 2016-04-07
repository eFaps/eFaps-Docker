FROM ubuntu:16.04
MAINTAINER Jan Moxter <jan.moxter@innobix.com>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r efaps && useradd -r -g efaps efaps

#update the standart ubuntutomost current
RUN apt-get update && apt-get upgrade -y 

#install Java 8
RUN apt-get install openjdk-8-jdk -y --no-install-recommends \
	 && apt-get install curl -y --no-install-recommends

ENV JETTY_HOME /efaps
RUN mkdir -p "$JETTY_HOME"


ENV JETTY_VERSION 9.3.8.v20160314

ENV JETTY_TGZ_URL https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/$JETTY_VERSION/jetty-distribution-$JETTY_VERSION.tar.gz

# GPG Keys are personal keys of Jetty committers (see https://dev.eclipse.org/mhonarc/lists/jetty-users/msg05220.html)
ENV JETTY_GPG_KEYS \
       # 1024D/8FB67BAC 2006-12-10 Joakim Erdfelt <joakime@apache.org>
       B59B67FD7904984367F931800818D9D68FB67BAC \
       # 1024D/D7C58886 2010-03-09 Jesse McConnell (signing key) <jesse.mcconnell@gmail.com>
       5DE533CB43DAF8BC3E372283E7AE839CD7C58886
       
RUN set -xe \
	&& curl -SL "$JETTY_TGZ_URL" -o jetty.tar.gz \
	&& curl -SL "$JETTY_TGZ_URL.asc" -o jetty.tar.gz.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && for key in $JETTY_GPG_KEYS; do \
                gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; done \
	&& gpg --batch --verify jetty.tar.gz.asc jetty.tar.gz \
	&& rm -r "$GNUPGHOME"        