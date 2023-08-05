FROM ubuntu:22.04

ARG USERNAME=adaptabuild
ARG USER_UID=2000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
RUN apt update && \
    apt install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Add a layer with the correct locale and timezone

ENV LANG en_US.UTF-8
ENV TZ Etc/EST

ARG DEBIAN_FRONTEND=noninteractive

# For more information on managing locales in mimimal Ubuntu docker
# images, see: https://hub.docker.com/_/ubuntu

RUN apt install -y tzdata \
                   locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt install -y git=1:2.34.1-1ubuntu1.9 \
                   python3=3.10.6-1~22.04 \
                   build-essential=12.9ubuntu3 \
                   gcc-arm-none-eabi=15:10.3-2021.07-4 \
                   stlink-tools=1.7.0+ds-1 \
                   gdb-multiarch=12.1-0ubuntu1~22.04 \ 
                   binutils-multiarch=2.38-4ubuntu2.3 && \
    ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb

RUN apt install -y python3-pip=22.0.2+dfsg-1ubuntu0.3 \
                   python3-sphinx=4.3.2-1

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

#    pkg-config \
#                    udev \
#                    libudev-dev \
#                    usbutils \
#                    minicom \
#                    gdb-multiarch
# 
# Don't do this until we are ready to rebuild the machine a final time
# RUN apt -y autopurge && \
#     apt -y autoclean && \
#     apt -y autoremove && \
#     rm -rf /var/lib/apt/lists/*

# RUN  rustup component add llvm-tools-preview && \
#                  cargo install cargo-binutils && \
#                  cargo install cargo-embed && \
#                  rustup target add thumbv7em-none-eabihf
# 
# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
