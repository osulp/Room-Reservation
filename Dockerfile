FROM ruby:2.1.1

# dependencies
RUN \
  apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  git-core \
  libcurl4-openssl-dev \
  libc6-dev \
  libreadline-dev \
  libssl-dev \
  libxslt1-dev \
  libyaml-dev \
  zlib1g-dev \
  imagemagick \
  git \
  curl \
  autoconf \
  ca-certificates \
  libffi-dev \
  libgdbm-dev \
  libgmp-dev \
  libgmp3-dev \
  libncurses5-dev \
  libqdbm-dev \
  libreadline6-dev \
  libz-dev \
  systemtap \
  ruby-dev \
  sqlite3 \
  libsqlite3-dev \
  openssh-client \
  openssh-server \
  # vim \
  libgtk2.0-dev \
  libvips \
  g++ \
  gcc \
  make \
  cmake \
  memcached \
  libmysqlclient-dev \
  libxml2 \
  libxml2-dev \
  libxslt-dev \
  libxslt1.1 \
  libqt4-dev \
  libqtwebkit-dev \
  xvfb \
  xauth \
  libicu-dev \
  libcurl3 \
  libcurl3-gnutls \
  mysql-client
  # redis-server

RUN \
  apt-get autoremove -y && \
  apt-get clean all

# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

# # Install phantomjs
# # Env
# ENV PHANTOMJS_VERSION 2.1.1
#
# # Commands
# RUN \
#   apt-get update && \
#   apt-get upgrade -y && \
#   apt-get install -y wget libfreetype6 libfontconfig bzip2 && \
#   mkdir -p /srv/var && \
#   wget -q --no-check-certificate -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
#   tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
#   rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
#   mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
#   ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
#   git clone https://github.com/n1k0/casperjs.git /srv/var/casperjs && \
#   ln -s /srv/var/casperjs/bin/casperjs /usr/bin/casperjs && \
#   apt-get autoremove -y && \
#   apt-get clean all
#
# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
RUN mkdir /roomres

# Install bundler.
RUN gem install bundler
RUN gem install faye -v 1.0.1
RUN gem install rails -v 4.1.0

WORKDIR /roomres
COPY Gemfile Gemfile
COPY . .
RUN  bundle install
ADD . /roomres
WORKDIR /roomres
EXPOSE 8983
EXPOSE 9292
EXPOSE 9020
EXPOSE 3000
EXPOSE 6379
EXPOSE 11211
