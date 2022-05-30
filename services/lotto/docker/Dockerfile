FROM amazoncorretto:11-alpine

LABEL name="lotto-service" version=0.0.1-snapshot \
 org.chiwoo.image.created="2022-01" \
 org.chiwoo.image.version="amazoncorretto-11" \
 org.chiwoo.image.title="lotto-service" \
 org.chiwoo.image.description="Dockerfile for Lotto Service" \
 org.chiwoo.image.source="https://github.com/"

ENV JAVA_OPTS="-server -Xverify:none"
ENV JAVA_OPTS="$JAVA_OPTS -Dsun.misc.URLClassPath.disableJarChecking=true"

# RUN apk add --no-cache bash curl
WORKDIR /app

COPY ./*.jar /app/springApp.jar
COPY ./entrypoint.sh /app/

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]

# docker build -t "symplesims/lotto-service:0.0.1" .
