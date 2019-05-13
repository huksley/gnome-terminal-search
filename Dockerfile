FROM ubuntu:18.04
# baseline
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install make gcc autoconf automake dpkg-dev ca-certificates curl build-essential pkg-config locales

# Enable source repos
RUN sed -i '/deb-src/s/^# //' /etc/apt/sources.list && apt update

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales


# Create user
ARG USERNAME=builder
ARG USERID=1000
ARG HOMEDIR=/buildroot
RUN useradd -m -u $USERID -d $HOMEDIR -s /bin/sh $USERNAME

# Fetch deps (as root)
RUN apt-get -y build-dep gnome-terminal

# Fetch missing additional dependencies
RUN apt-get -y install libpcre3-dev libpcre2-dev libgconf2-dev

# Switch to user
USER $USERNAME
ENV HOME=$HOMEDIR
WORKDIR $HOMEDIR

# Download sources into local dir
RUN apt-get -y source gnome-terminal

ARG PATCHFILE=search_on_google.patch
ARG APPVER=gnome-terminal-3.28.2
ADD ${PATCHFILE} ./
RUN cd ${APPVER} && \
	./configure --disable-search-provider && \
	patch -p1 < ../${PATCHFILE} && \
	make

