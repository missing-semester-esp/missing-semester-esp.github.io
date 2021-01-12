FROM jekyll/jekyll:3.8.0

WORKDIR /tmp

ENV BUNDLER_VERSION 2.1.4
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1

ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/

RUN gem install bundler -i /usr/gem -v 2.1.4
RUN bundle update activesupport
RUN bundle install

WORKDIR /srv/jekyll
