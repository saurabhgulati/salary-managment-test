
ARG RUBY_VERSION=3.3.6
FROM ruby:3.3.6
RUN apt-get update -y
RUN apt-get install exiftool -y
RUN apt-get update && apt-get install -y imagemagick

WORKDIR /app

COPY . .
RUN bundle install
