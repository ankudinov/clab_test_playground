FROM avdteam/avd-all-in-one:latest

ENV _IN_CONTAINER="True"

# install clab
RUN bash -c "$(curl -sL https://get.containerlab.dev)"

RUN pip3 install eos-downloader

# add token to be used by eos-download
# the real token must be set on the system with `export ARISTA_TOKEN="<the-token>"`
# and will be passed to the container during build phase
ENV ARISTA_TOKEN="None"

# if not running as VScode devcontainer, start in projects
WORKDIR /home/avd/projects
