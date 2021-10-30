FROM jenkins/jenkins:lts-jdk11

USER root
WORKDIR /root

RUN apt-get -y update

RUN echo "instalar software necesario"
RUN apt-get install -y npm net-tools wget

RUN  echo "instalar google chrome descargando .deb"
ARG CHROME_VERSION="95.0.4638.54-1"
RUN wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb \
  && apt install -y /tmp/chrome.deb \
  && rm /tmp/chrome.deb

RUN echo "copiamos chromedriver"
COPY ./chromedriver /usr/local/bin/

RUN apt install python3
RUN apt-get install -y python3-pip
RUN pip install virtualenv

