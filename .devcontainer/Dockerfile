FROM python:3.9.5-slim

ARG _UNAME="avd"
ARG _UID="1000"
ARG _GID="1000"
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

# add non-root user
RUN useradd -md /home/${_UNAME} -s /bin/zsh -u ${_UID} ${_UNAME} -g ${_GID} \
    && echo "${_UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    # add docker and sudo to avd group
    && usermod -aG docker ${_UNAME} \
    && usermod -aG sudo ${_UNAME}
USER ${_UNAME}
ENV HOME=/home/${_UNAME}
ENV PATH=$PATH:/home/${_UNAME}/.local/bin

WORKDIR /home/${_UNAME}

# install zsh
RUN wget --quiet https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
    && echo 'PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"' >> ${HOME}/.zshrc \
    && echo 'PROMPT+=" %{$fg[blue]%}(%{$fg[red]%}A%{$fg[green]%}V%{$fg[blue]%}D 🐳%{$fg[blue]%})%{$reset_color%}"' >> ${HOME}/.zshrc \
    && echo 'PROMPT+=" %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)"' >> ${HOME}/.zshrc \
    && echo 'plugins=(ansible common-aliases safe-paste git jsontools history git-extras)' >> ${HOME}/.zshrc \
    # redirect to &>/dev/null is required to silence `agent pid XXXX` message from ssh-agent
    && echo 'eval `ssh-agent -s` &>/dev/null' >> ${HOME}/.zshrc \
    && echo 'export TERM=xterm-256color' >>  $HOME/.zshrc \
    && echo "export LC_ALL=C.UTF-8" >> $HOME/.zshrc \
    && echo "export LANG=C.UTF-8" >> $HOME/.zshrc \
    && echo 'export PATH=$PATH:/home/avd/.local/bin' >> $HOME/.zshrc

# add entrypoint script
COPY .devcontainer/entrypoint.sh /bin/entrypoint.sh
RUN sudo chmod +x /bin/entrypoint.sh
# use ENTRYPOINT instead of CMD to ensure that entryscript is always executed
ENTRYPOINT [ "/bin/entrypoint.sh" ]

# add AVD gitconfig to be used if container is not called as VScode devcontainer
COPY .devcontainer/gitconfig /home/avd/gitconfig-avd-base-template

WORKDIR /home/${_UNAME}/projects
