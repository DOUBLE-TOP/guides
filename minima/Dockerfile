FROM ubuntu:20.04

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update \
    && apt install mc wget jq libfontconfig1 libxtst6 libxrender1 libxi6 java-common libasound2 -y \
    && wget https://cdn.azul.com/zulu/bin/zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb \
    && dpkg -i zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb \
    && rm -f zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb

RUN cd /opt/ && \
    wget https://github.com/minima-global/Minima/raw/master/jar/minima.jar

EXPOSE 9001 9002 9003 9004

ENTRYPOINT ["/usr/bin/java", "-Xmx1G", "-jar", "/opt/minima.jar", "-daemon"]
