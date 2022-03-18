FROM ruby:2.6.3

# Install Dependancies
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  git \
  libgmp3-dev \
  libpq-dev \
  mariadb-client \
  gettext \
  vim

# Setup Environment
ARG INSTALL_PATH=/usr/src/app
ENV INSTALL_PATH $INSTALL_PATH
ENV BUNDLE_PATH=/bundle/ \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV Path="${BUNDLE_BIN}:${PATH}"

WORKDIR $INSTALL_PATH

RUN touch ~/.bashrc
RUN echo "alias rails='bundle exec rails'" >> ~/.bashrc
RUN echo "alias rspec='RAILS_ENV=test bundle exec rspec'" >> ~/.bashrc
RUN echo "export EDITOR=vim" >> ~/.bashrcf

# Install yarn+node from packages
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn

# Re-build from here if Gemfile or .lock change
COPY ./src/Gemfile* ./
RUN gem install bundler

#RUN bundle config set without 'Postgres thin and rollbar'
RUN bundle config set without 'pgsql thin rollbar'
RUN bundle install
RUN yarn install

# Expose correct port
EXPOSE 3001
