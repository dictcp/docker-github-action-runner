FROM debian:buster-slim

ARG GITHUB_RUNNER_VERSION="2.168.0"

ENV RUNNER_NAME "runner"
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
        net-tools \
        busybox \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        lsb-release \
        software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ref: https://github.com/urcomputeringpal/actions-runner-kubernetes/blob/master/install.sh
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y \
      docker-ce \
      git \
      inetutils-ping \
      sudo \
      ;

USER github
WORKDIR /home/github

RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
