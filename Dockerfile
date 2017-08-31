FROM maven:3.5.0-alpine

RUN apk --no-cache add curl \ 
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/alexellis/faas/releases/download/0.6.2/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl --no-cache

WORKDIR /root/
COPY function           function
WORKDIR /root/function/
COPY function/pom.xml	  .
RUN mvn package

WORKDIR /root/
COPY Main.java          .
COPY pom.xml            .
RUN mvn package

ENV fprocess="java Main"

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
