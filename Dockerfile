# FROM ubuntu:18.04

# RUN apt update && apt install software-properties-common -y
# RUN add-apt-repository ppa:deadsnakes/ppa && apt install python3.8 python3.8-distutils -y
# RUN ln -s /usr/bin/pip3 /usr/bin/pip && \
#     ln -s /usr/bin/python3.8 /usr/bin/python
# RUN wget https://bootstrap.pypa.io/get-pip.py && python3.8 get-pip.py
FROM python:3.8
# FROM nvidia/cuda@sha256:4df157f2afde1cb6077a191104ab134ed4b2fd62927f27b69d788e8e79a45fa1

WORKDIR /app

COPY ../docker_rsa.pub /app
COPY ../requirements.txt /app

EXPOSE 22

RUN apt-get update
RUN apt-get install -y \
    curl \
    git \
    vim \
    wget \
    gcc \
    libhdf5-serial-dev \
    python3-mpi4py \
    openssh-server \ 
    sudo \
    ffmpeg \
    libsm6 \
    libxext6 \
    libglew-dev \
    libosmesa6-dev \
    libgl1-mesa-glx \
    libglfw3 \
    patchelf \
    virtualenv \ 
    libopenmpi-dev \
    # software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Install python 3.8
# RUN DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:deadsnakes/ppa && apt-get update
# RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes python3.8-dev python3.8 python3-pip
# RUN virtualenv --python=python3.8 env

# RUN rm /usr/bin/python
# RUN ln -s /env/bin/python3.8 /usr/bin/python
# RUN ln -s /env/bin/pip3.8 /usr/bin/pip
# RUN ln -s /env/bin/pytest /usr/bin/pytest

RUN mkdir /var/run/sshd

RUN mkdir -p /root/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco \
    && rm mujoco.tar.gz

ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN cat ./docker_rsa.pub >> ~/.ssh/authorized_keys

# RUN virtualenv /venv

RUN pip install -r ./requirements.txt
# Fork version of D4RL
RUN pip install git+https://github.com/rail-berkeley/d4rl@master#egg=d4rl
# RUN pip install -e .
RUN mkdir experiments
RUN mkdir data

ENV EXP_DIR /app/experiments
ENV DATA_DIR /app/data

RUN service ssh start

CMD ["/usr/sbin/sshd", "-D"]
# CMD ["tail", "-f", "/dev/null"]