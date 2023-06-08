FROM ruby:2.6-slim

# GitHub build args that we can expose in the image
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

# Values we set in more than one place in this file
ARG ARDUINO_CI_VERSION=1.6.2
ARG ARDUINO_CI_ACTION_REPO="https://github.com/ArduinoCI/action"
ARG ARDUINO_CI_MAINTAINER="Arduino Continuous Integration <arduino.continuous.integration@gmail.com>"

## IF USING A RELEASED GEM - also check lower in the file
ARG ARDUINO_CI_GITREPO="https://github.com/Arduino-CI/arduino_ci.git"
ARG ARDUINO_CI_GITREF="tag: 'v$ARDUINO_CI_VERSION'"
## ELSE
# ARG ARDUINO_CI_GITREPO="https://github.com/ianfixes/arduino_ci.git"
# ARG ARDUINO_CI_GITREF="branch: '2023-06-07_nano_every'"
## END

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
      repository=$ARDUINO_CI_ACTION_REPO \
      homepage=$ARDUINO_CI_ACTION_REPO \
      arduino_ci_gem_version=$ARDUINO_CI_VERSION \
      arduino_ci_gem_repo=$ARDUINO_CI_GITREPO \
      arduino_ci_gitref=$ARDUINO_CI_GITREF

# Values for debugging
ENV BUILD_DATE=$BUILD_DATE \
    BUILD_REVISION=$BUILD_REVISION \
    BUILD_VERSION=$BUILD_VERSION

ENV BUNDLE_GEMFILE=/action/Gemfile \
    DEBIAN_FRONTEND=noninteractive

# Note that python is installed not because we need it but because Arduino platforms need it
RUN true \
  && apt-get update \
  && apt-get install -qq --no-install-recommends \
      git \
      curl \
      g++ \
      time \
      jq \
      python3 \
      python3-pip \
      python3-yaml \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install pyserial \
  && pip3 install pyserial

# install arduino_ci
RUN true \
  && mkdir -p /action/bundle \
  && echo "source 'https://rubygems.org'" > $BUNDLE_GEMFILE \
## IF USING A RELEASED GEM
  && echo "gem 'arduino_ci', '=$ARDUINO_CI_VERSION'" >> $BUNDLE_GEMFILE \
## ELSE
#  && echo "gem 'arduino_ci', git: '$ARDUINO_CI_GITREPO', $ARDUINO_CI_GITREF" >> $BUNDLE_GEMFILE \
## END
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

# # Install common platforms by converting YAML to JSON and generating installation commands to run
# #
# # Although it seems wasteful to pull in python dependencies for just this, remember that (some) arduino
# # platforms themselves require python to be available on the host, so we are taking advantage of a
# # package that is already required.
# RUN true \
#   && python3 -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < $(bundle show arduino_ci)/misc/default.yml \
#   | jq -r '.packages | to_entries[] \
#            | "arduino-cli core install \(.key) --additional-urls \(.value.url)"' \
#   | sh


# Just like that
ENTRYPOINT ["bundle", "exec", "/action/bundle/ruby/2.6.0/bin/arduino_ci.rb"]
