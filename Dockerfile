FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

ARG APT_MIRROR="jp"
RUN sed --in-place --regexp-extended "s|(//)(archive\.ubuntu)|\1${APT_MIRROR}.\2|" /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgl1-mesa-glx \
        python3-dev \
        python3-pip \
        python3-setuptools \
        wget \
    && rm -rf /var/lib/apt/lists/*

ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID user \
    && adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user \
    && usermod -a -G sudo user \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "alias python='python3.6'" >> /home/user/.bashrc

WORKDIR /home/user/dvr
COPY . .

RUN python3 -m pip install pip==20.0.2 \
    && python3 -m pip install --no-cache-dir -r requirements.txt \
    && rm -f requirements.txt

ARG DOWNLOAD_MODELS=1
RUN if [ ${DOWNLOAD_MODELS} -eq 1 ]; then \
        wget -nv https://download.pytorch.org/models/resnet18-5c106cde.pth -P /home/user/.cache/torch/checkpoints/; \
        wget -nv https://s3.eu-central-1.amazonaws.com/avg-projects/differentiable_volumetric_rendering/models/single_view_reconstruction/multi-view-supervision/ours_combined-af2bce07.pt -P /home/user/.cache/torch/checkpoints/; \
    fi \
    && wget -nv https://github.com/imageio/imageio-binaries/raw/master/freeimage/libfreeimage-3.16.0-linux64.so -P /home/user/.imageio/freeimage/ \
    && python3 setup.py build_ext --inplace \
    && chown -R user:user /home/user/

USER user
