FROM ubuntu:16.04
MAINTAINER Jan Moxter <jan.moxter@innobix.com>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r efaps && useradd -r -g efaps efaps

#update the standart ubuntutomost current
RUN apt-get update && apt-get upgrade -y 

#install Java 8, curl, tar
RUN apt-get install openjdk-8-jdk -y --no-install-recommends \
	 && apt-get install curl -y --no-install-recommends \
	 && apt-get install tar -y --no-install-recommends

#Where the Jetty Distribution will be unpacked into
ENV JETTY_HOME /opt/jetty
ENV PATH $JETTY_HOME/bin:$PATH
RUN mkdir -p "$JETTY_HOME"
WORKDIR $JETTY_HOME

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
	&& rm -r "$GNUPGHOME" \
	&& tar -xvf jetty.tar.gz --strip-components=1 --directory "$JETTY_HOME" \
	&& rm -fr demo-base javadoc \
	&& rm jetty.tar.gz*     

#Where your specific set of webapps will be located, including all of the configuration required of the server to make them operational.	
ENV JETTY_BASE /opt/web/efapsbase
RUN mkdir -p "$JETTY_BASE"/logs
	 
WORKDIR $JETTY_BASE

RUN java -jar "$JETTY_HOME/start.jar" --add-to-startd=http,plus,jaas

ENV JETTY_RUN /run/jetty
ENV JETTY_STATE $JETTY_RUN/jetty.state
ENV TMPDIR /tmp/jetty

RUN set -xe \
	&& mkdir -p "$JETTY_RUN" "$TMPDIR" \
	&& chown -R efaps:efaps "$JETTY_HOME" "$JETTY_RUN" "$TMPDIR" "$JETTY_BASE"

# create the start script for daemon run
RUN cp "$JETTY_HOME/bin/jetty.sh" /etc/init.d/jetty
RUN echo "JETTY_HOME=$JETTY_HOME" > /etc/default/jetty 
RUN	echo "JETTY_BASE=$JETTY_BASE" >> /etc/default/jetty 
RUN	echo "JETTY_STATE=$JETTY_STATE" >> /etc/default/jetty 
RUN	echo "JETTY_LOGS=$JETTY_BASE/logs" >> /etc/default/jetty 
RUN	echo "JETTY_USER=efaps" >> /etc/default/jetty

# RUN echo "TMPDIR=$TMPDIR" >> /etc/default/jetty
	
# make the port 8080 accessible	
EXPOSE 8080

#ENTRYPOINT ["java","-Djava.io.tmpdir=/tmp/jetty","-jar","/usr/local/jetty/start.jar"]

