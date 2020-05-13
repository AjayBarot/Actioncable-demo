FROM ubuntu:16.04

RUN apt-get update \
&& apt-get install -y software-properties-common curl nodejs nodejs-legacy npm libpq-dev\
&& apt-get update

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" » /etc/profile

# Install rvm

RUN bash -c 'gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB'
RUN bash -c '\curl -sSL https://get.rvm.io | bash'
RUN curl -L https://get.rvm.io | bash -s stable

RUN bash -c 'source /usr/local/rvm/scripts/rvm; rvm install ruby-2.4.1'
RUN bash -c 'source /usr/local/rvm/scripts/rvm; gem install bundler'

# Install redis
RUN apt-get install -y redis-server

# Copy gemfiles
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

# Install gems
RUN bash -c 'source /usr/local/rvm/scripts/rvm; cd /app && bundle install'

# Copy app
ADD . /app
COPY ./config/database.yml /app/config/database.yml

# Redirect logs
RUN bash -c 'touch /app/log/development.log'
RUN ln -sf /dev/stdout /app/log/development.log

EXPOSE 3000
ENTRYPOINT "/app/run.sh"