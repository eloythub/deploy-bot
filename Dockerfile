FROM ubuntu:latest

MAINTAINER Mahan Hazrati<eng.mahan.hazrati@gmail.com>

RUN apt-get update && apt-get upgrade -y

# install google cloud sdk
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y -qq --no-install-recommends wget unzip python openssh-client python-openssl && apt-get clean

ENV HOME /
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip --no-check-certificate && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-java app-engine-python app kubectl alpha beta gcd-emulator pubsub-emulator cloud-datastore-emulator app-engine-go bigtable

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json


RUN mkdir /.ssh
ENV PATH /google-cloud-sdk/bin:$PATH
VOLUME ["/.config"]

# install hubot
ENV BOTDIR /opt/bot

RUN wget -q -O - https://deb.nodesource.com/setup_7.x | bash - && \
  apt-get install -y git build-essential nodejs nodejs-legacy npm && \
  rm -rf /var/lib/apt/lists/* && \
  git clone --depth=1 https://github.com/nhoag/bot.git ${BOTDIR}

WORKDIR ${BOTDIR}

RUN npm install

ENTRYPOINT bash