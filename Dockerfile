# .devcontainer/Dockerfile
FROM arm64v8/ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        vim \
        zsh \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# install steampipe
RUN curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh > /tmp/steampipe-install.sh
RUN chmod 755 /tmp/steampipe-install.sh
RUN /bin/sh -c /tmp/steampipe-install.sh
CMD steampipe plugin install steampipe

# Set up non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    apt-get update && apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
