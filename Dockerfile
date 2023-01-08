FROM ruby:2.6-slim

# GitHub build args that we can expose in the image
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

# Values we set in more than one place in this file
ARG ARDUINO_CI_ACTION_REPO="https://github.com/ArduinoCI/action"
ARG ARDUINO_CI_MAINTAINER="Arduino Continuous Integration <arduino.continuous.integration@gmail.com>"
ARG ARDUINO_CI_GITREPO="https://github.com/ArduinoCI/arduino_ci.git"
ARG ARDUINO_CI_GITREF="tag: 'v1.4.0'"
#ARG ARDUINO_CI_GITREPO="https://github.com/ianfixes/arduino_ci.git"
#ARG ARDUINO_CI_GITREF="branch: '2021-01-07_beta'"

LABEL com.github.actions.name="Arduino CI" \
      com.github.actions.description="Unit testing and example compilation for Arduino libraries" \
      com.github.actions.color="blue" \
      com.github.actions.icon="cpu" \
      maintainer=$ARDUINO_CI_MAINTAINER \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$BUILD_REVISION \
      org.opencontainers.image.version=$BUILD_VERSION \
      org.opencontainers.image.authors=$ARDUINO_CI_MAINTAINER \
      org.opencontainers.image.url=$ARDUINO_CI_ACTION_REPO \
      org.opencontainers.image.source=$ARDUINO_CI_REPO \
      org.opencontainers.image.documentation=$ARDUINO_CI_ACTION_REPO \
      org.opencontainers.image.vendor="Arduino CI" \
      org.opencontainers.image.description="Unit testing and example compilation for Arduino libraries" \
      repository=$$ARDUINO_CI_ACTION_REPO \
      homepage=$ARDUINO_CI_ACTION_REPO

# Values for debugging
ENV BUILD_DATE=$BUILD_DATE \
    BUILD_REVISION=$BUILD_REVISION \
    BUILD_VERSION=$BUILD_VERSION

ENV BUNDLE_GEMFILE=/action/Gemfile \
    DEBIAN_FRONTEND=noninteractive

RUN true \
  && apt-get update \
  && apt-get install -qq --no-install-recommends \
      git \
      curl \
      g++ \
      time \
      python \
      python3 \
      python3-pip \
  && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py \
  && python get-pip.py \
  && rm -rf get-pip.py \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install pyserial \
  && pip3 install pyserial

# install arduino_ci
RUN true \
  && mkdir -p /action/bundle \
  && echo "source 'https://rubygems.org'" > $BUNDLE_GEMFILE \
#  && echo "gem 'arduino_ci', git: '$ARDUINO_CI_GITREPO', $ARDUINO_CI_GITREF" >> $BUNDLE_GEMFILE \
  && echo "gem 'arduino_ci', '=1.4.0'" >> $BUNDLE_GEMFILE \
  && cat $BUNDLE_GEMFILE \
  && bundle install --gemfile /action/Gemfile --path /action/bundle \
  && find /action |grep arduino_ci.rb

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install the version of the CLI backend specified in the project, such that it's in $PATH for later discovery
# then verify that the package downloaded to a usable location, and create the libraries directory
RUN curl -fsSL "https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh" \
  | BINDIR=/usr/local/bin sh -s $(bundle exec ruby -e "require 'arduino_ci'; print ArduinoCI::ArduinoInstallation::DESIRED_ARDUINO_CLI_VERSION") \
  && echo "Now running arduino ensure_arduino_installation.rb" \
  && bundle exec time /action/bundle/ruby/2.6.0/bin/ensure_arduino_installation.rb

# Just like that
ENTRYPOINT ["bundle", "exec", "/action/bundle/ruby/2.6.0/bin/arduino_ci.rb"]
