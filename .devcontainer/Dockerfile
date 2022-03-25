FROM python:3.9.5-slim

ARG _DOCKER_COMPOSE_VERSION="2.3.3"

# install tools permanently
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    make \
    wget \
    curl \
    less \
    git \
    zsh \
    vim \
    sudo \
    sshpass \
    git-extras \
    openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# install docker in docker
RUN curl -fsSL https://get.docker.com | sh \
    && curl -L "https://github.com/docker/compose/releases/download/${_DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# install clab
RUN bash -c "$(curl -sL https://get.containerlab.dev)"
