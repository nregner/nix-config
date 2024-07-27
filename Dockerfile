# build
FROM ubuntu:24.04 as builder
LABEL maintainer=michel.promonet@free.fr
ARG USERNAME=dev
WORKDIR /webrtc-streamer
COPY . /webrtc-streamer

ENV PATH /depot_tools:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget git python3 python3-pkg-resources g++ autoconf automake libtool xz-utils libpulse-dev libasound2-dev libgtk-3-dev libxtst-dev libssl-dev librtmp-dev cmake make pkg-config p7zip-full sudo

RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /depot_tools

RUN useradd -m -s /bin/bash $USERNAME \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME
RUN mkdir /webrtc \
	&& cd /webrtc \
	&& fetch --no-history --nohooks webrtc
RUN cd /webrtc \
	&& sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS \
	&& gclient sync

