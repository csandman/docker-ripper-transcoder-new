FROM phusion/baseimage
LABEL maintainer="Chris Sandvik <chris.sandvik@gmail.com>"

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
RUN \
  usermod -u 99 nobody && \
  usermod -g 100 nobody && \
  usermod -d /home nobody && \
  chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# EXTRA PERMISSIONS?
# RUN chown root:root /tmp
# RUN chmod ugo+rwXt /tmp

# Move Files
COPY root/ /
RUN chmod +x /etc/my_init.d/*.sh

# Install software
RUN apt-get update \
  && add-apt-repository -y ppa:stebbins/handbrake-releases \
  && apt-get -y --allow-unauthenticated install \
  wget \
  eject \
  curl \
  ruby \
  ffmpeg \
  mpv \
  mkvtoolnix \
  mp4v2-utils \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && apt-get -y --allow-unauthenticated install nodejs \
  && npm install batch-transcode-video -g 

RUN set -ex \
  # Install application dependencies
  # && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/* \
  && gem install video_transcoding \
  && mkdir /data

# MakeMKV setup by github.com/tobbenb
RUN chmod +x /tmp/install/install.sh && sleep 1 && /tmp/install/install.sh && rm -r /tmp/install
