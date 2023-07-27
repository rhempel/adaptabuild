FROM ubuntu:22.04

ARG USERNAME=adaptabuild
ARG USER_UID=2000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
RUN apt-get update && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Add a layer with the correct locale and timezone

ENV LANG=en_US.UTF-8
ENV TZ=Etc/EST

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y tzdata \
                       locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

RUN apt-get update && \
    apt install -y git \
                   python3

#                   build-essential \
#                   gcc-arm-none-eabi

# Make a new RUN for each app we need to install, then consolidate for final
# machine build - speeds up rebuilds by re-using layers

RUN apt-get update && \
    apt install -y python3-pip \
                    python3-sphinx

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

