FROM ruby:2.7


COPY [".", "/usr/src"]
WORKDIR "/usr/src"

RUN ["gem", "install", "bundler"]
RUN ["bundle", "install"]
EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "-w", "--host", "0.0.0.0"] 