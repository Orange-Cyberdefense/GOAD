FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y python3-pip

RUN pip install --upgrade pip
RUN pip install ansible-core==2.12.6
RUN pip install pywinrm

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    sshpass lftp rsync openssh-client

COPY ./ansible/requirements.yml .

RUN ansible-galaxy install -r requirements.yml
