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
    && echo "export PATH=$PATH:/home/${_UNAME}/.local/bin" >> $HOME/.zshrc

# add entrypoint script
COPY .devcontainer/entrypoint.sh /bin/entrypoint.sh
RUN sudo chmod +x /bin/entrypoint.sh
# use ENTRYPOINT instead of CMD to ensure that entryscript is always executed
ENTRYPOINT [ "/bin/entrypoint.sh" ]

# add AVD gitconfig to be used if container is not called as VScode devcontainer
COPY .devcontainer/gitconfig /home/${_UNAME}/gitconfig-avd-base-template

# ^ ^ ^
# | | |     The section above usually remains unchanged between releases

# | | |     The section below will be updated for every release
# V V V

# change this for every release
ENV _AVD_VERSION="3.3.3"
ENV _CVP_VERSION="3.3.1"

# labels to be changed for every release
LABEL maintainer="Arista Ansible Team <ansible@arista.com>"
LABEL com.example.version="avd3.3.3_cvp3.3.1_debian"
LABEL vendor1="Arista"
LABEL com.example.release-date="2022-03-22"
LABEL com.example.version.is-production="False"

# install ansible.cvp, ansible.avd collections and their requirements
# ansible.avd pip requirements are superior, ansible.cvp requirements will be ignored
RUN wget --quiet https://raw.githubusercontent.com/aristanetworks/ansible-avd/v${_AVD_VERSION}/ansible_collections/arista/avd/requirements.txt \
    && wget --quiet https://raw.githubusercontent.com/aristanetworks/ansible-avd/v${_AVD_VERSION}/ansible_collections/arista/avd/requirements-dev.txt \
    && pip3 install "ansible-core>=2.11.3,<2.13.0" \
    && pip3 install --user --no-cache-dir -r requirements.txt \
    && pip3 install --user --no-cache-dir -r requirements-dev.txt \
    # install ansible.cvp first to control version explicitely without installing dependencies
    && ansible-galaxy collection install arista.avd:==${_CVP_VERSION} --no-deps \
    # install ansible.avd and it's dependencies, ansible.cvp will not be installed as it already exists
    && ansible-galaxy collection install arista.avd:==${_AVD_VERSION} \
    # install community.general to support callback plugins in ansible.cfg, etc.
    && ansible-galaxy collection install community.general

# if not running as VScode devcontainer, start in projects
WORKDIR /home/${_UNAME}/projects
