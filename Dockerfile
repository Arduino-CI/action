FROM ruby:2.6-slim

# GitHub build args that we can expose in the image
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

# Values we set in more than one place in this file
ARG ARDUINO_CI_REPO="https://github.com/ArduinoCI/action"
ARG ARDUINO_CI_MAINTAINER="Ian <ianfixes@gmail.com>"

LABEL com.github.actions.name="Arduino CI" \
      com.github.actions.description="Unit testing and example compilation for Arduino libraries" \
      com.github.actions.color="blue" \
      com.github.actions.icon="cpu" \
      maintainer=$ARDUINO_CI_MAINTAINER \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$BUILD_REVISION \
      org.opencontainers.image.version=$BUILD_VERSION \
      org.opencontainers.image.authors=$ARDUINO_CI_MAINTAINER \
      org.opencontainers.image.url=$ARDUINO_CI_REPO \
      org.opencontainers.image.source=$ARDUINO_CI_REPO \
      org.opencontainers.image.documentation=$ARDUINO_CI_REPO \
      org.opencontainers.image.vendor="Arduino CI" \
      org.opencontainers.image.description="Unit testing and example compilation for Arduino libraries" \
      repository=$$ARDUINO_CI_REPO \
      homepage=$ARDUINO_CI_REPO

# Values for debugging
ENV BUILD_DATE=$BUILD_DATE
ENV BUILD_REVISION=$BUILD_REVISION
ENV BUILD_VERSION=$BUILD_VERSION

# bundler uses this
ENV BUNDLE_GEMFILE=/action/Gemfile

RUN true \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      git \
      curl \
      g++ \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install arduino_ci
RUN true \
  && mkdir -p /action/bundle \
  && echo "source 'https://rubygems.org'" > $BUNDLE_GEMFILE \
  && echo "gem 'arduino_ci', git: 'https://github.com/Arduino-CI/arduino_ci.git', tag: 'v1.0.0'" >> $BUNDLE_GEMFILE \
  && bundle install --gemfile /action/Gemfile --path /action/bundle \
  && find /action |grep arduino_ci.rb

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install the version of the CLI backend specified in the project
RUN curl -fsSL "https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh" \
  | BINDIR=/usr/local/bin sh -s $(bundle exec ruby -e "require 'arduino_ci'; print ArduinoCI::ArduinoInstallation::DESIRED_ARDUINO_CLI_VERSION")

# TO THE MAINTAINER: optionally, we can verify that the package downloaded to a usable location
#   by running the standalone installation command and confirming that:
#     1. it doesn't produce any output
#     2. it doesn't take any time
# RUN bundle exec time /action/bundle/ruby/2.6.0/bin/ensure_arduino_installation.rb

# Just like that
ENTRYPOINT ["bundle", "exec", "/action/bundle/ruby/2.6.0/bin/arduino_ci.rb"]
