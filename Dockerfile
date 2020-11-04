FROM docker.sunet.se/openjdk-jre-luna:luna7.4-jre11
VOLUME /tmp
VOLUME /etc/ssl
ADD target/sigval-service.jar /app.jar
ENV JAVA_OPTS=""
ADD start.sh /
RUN chmod a+rx /start.sh
ENTRYPOINT /start.sh
EXPOSE 8009
EXPOSE 8443
