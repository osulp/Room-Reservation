FROM ruby:2.5.1

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev mysql-client nodejs libreoffice imagemagick unzip ghostscript && \
  rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
RUN mkdir /roomres
WORKDIR /roomres

ADD Gemfile /roomres/Gemfile
ADD Gemfile.lock /roomres/Gemfile.lock
RUN gem install bundler
RUN bundle install
ADD . /roomres

EXPOSE 8983
EXPOSE 9292
EXPOSE 9020
EXPOSE 3000
EXPOSE 6379
EXPOSE 11211
