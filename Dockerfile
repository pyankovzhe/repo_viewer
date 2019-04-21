FROM ruby:2.6.2-alpine3.9 AS builder

RUN apk update && apk --update add \
  libcurl && \
apk --update add --virtual .build-dependencies \
  build-base \
  gcc \
  automake \
  ruby-dev \
  libc-dev

WORKDIR /app

FROM builder AS development
COPY Gemfile* /app/
RUN bundle install
COPY . /app

FROM development AS release
RUN apk del .build-dependencies

ENV APP_ENV=production
EXPOSE 4000

CMD ["puma", "-p", "4000" ]
