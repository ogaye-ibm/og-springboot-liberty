FROM adoptopenjdk/openjdk8-openj9 AS build-stage

#RUN apt-get update && \
    #apt-get install -y maven unzip

COPY . /project
WORKDIR /project

#RUN mvn --version
#RUN mvn -X initialize process-resources verify -DskipTests  #=> to get dependencies from maven
#RUN mvn clean package

RUN mkdir -p /config/apps && \
    mkdir -p /sharedlibs && \
    mkdir -p /config/lib && \
    cp ./liberty/config/server.xml /config && \
    cp ./liberty/config/*.properties /config && \
    cp ./liberty/config/jvm.options /config && \
    cp ./build/libs/*.*ar /config/apps/ && \
    if [ ! -z "$(ls ./liberty/lib)" ]; then \
        cp ./liberty/lib/* /sharedlibs && \
        cp ./liberty/lib/* /lib && \
        cp ./liberty/lib/* /config/lib; \
    fi

FROM ibmcom/websphere-liberty:kernel-java8-ibmjava-ubi

ARG SSL=true
ARG OPENJ9_SCC=false
ARG VERBOSE=true

ARG MP_MONITORING=true
ARG HTTP_ENDPOINT=false

RUN mkdir -p /opt/ibm/wlp/usr/shared/config/lib/global
RUN mkdir -p /opt/ibm/wlp/usr/shared/resources
RUN mkdir -p /opt/ibm/wlp/usr/servers/defaultServer

COPY --chown=1001:0 --from=build-stage /config/ /config/
COPY --chown=1001:0 --from=build-stage /config/*.properties /opt/ibm/wlp/usr/servers/defaultServer
COPY --chown=1001:0 --from=build-stage /sharedlibs/ /opt/ibm/wlp/usr/shared/config/lib/global

USER root
RUN configure.sh
USER 1001

# Upgrade to production license if URL to JAR provided
#ARG LICENSE_JAR_URL
#RUN \
#   if [ $LICENSE_JAR_URL ]; then \
#     wget $LICENSE_JAR_URL -O /tmp/license.jar \
#     && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
#     && rm /tmp/license.jar; \
#   fi
