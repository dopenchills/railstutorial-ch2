# syntax=docker/dockerfile:1
FROM ruby:2.7.6

WORKDIR /myapp

RUN apt-get update -qq && \
    apt-get install -y postgresql-client sqlite3 imagemagick --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# install yarn
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN set -x && apt-get update -y -qq && apt-get install -yq yarn

# install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN echo 'gem: --no-document' >> ~/.gemrc
RUN gem update --system
RUN gem install bundler -v 2.2.17

# nokogiriが動くようになる
RUN bundle config set force_ruby_platform true
RUN bundle _2.2.17_ install

# railsコマンドを使えるようにする (/myapp/bin/railsがなぜか使えない)
RUN gem install rails -v 6.0.4
RUN bundle _2.2.17_ update

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
