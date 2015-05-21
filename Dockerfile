#----------------------------------------------------------------------
# deb8gollum - Gollum wiki on Debian 8 (Jessie) with option to run as
#              a rack application.
#
# Version 0.4
#
# For usage info, just run the image without a command:
#   $ docker run --rm genebarker/deb8gollum
#
# For a rack application, see the example (gollumrack.rb), and be sure
# to append its required packages and gems to the respective RUN
# commands below.
#----------------------------------------------------------------------

FROM debian:8.0

MAINTAINER Eugene F. Barker <genebarker@gmail.com>

# install dependencies
RUN apt-get update && apt-get install -y \
  ruby \
  ruby-dev \
  libz-dev \
  libicu-dev \
  build-essential \
  git

# install gollum
RUN gem install gollum

# expose default port
EXPOSE 4567

# initialize wiki content
RUN mkdir /root/wiki
RUN git init /root/wiki

# copy in smart entrypoint script
COPY ./entrypoint.sh /
# set entry point
ENTRYPOINT ["/entrypoint.sh"]
