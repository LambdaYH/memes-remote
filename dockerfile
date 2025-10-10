# build stage
FROM python:3.11-slim-bookworm AS builder

# 依赖
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

# install PDM
RUN pip install -U pip setuptools wheel
RUN pip install pdm

# copy files
COPY pyproject.toml pdm.lock /tmp/

# install dependencies and project into the local packages directory
WORKDIR /tmp
RUN mkdir __pypackages__ && pdm sync --prod --no-editable

# run stage
FROM python:3.11-slim-bookworm

# retrieve packages from build stage
ENV PYTHONPATH=/pkgs
# copy files
WORKDIR /memes
COPY ./memes_remote/ /memes/memes_remote/
COPY .env entrypoint.sh pyproject.toml /memes/
COPY --from=builder /tmp/__pypackages__/3.11/lib /pkgs
COPY --from=builder /tmp/__pypackages__/3.11/bin/* /bin/
COPY ./fonts/* /usr/share/fonts/

# install deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends fontconfig fonts-noto-color-emoji libgl1-mesa-glx libgl1-mesa-dri gettext git curl \
    && fc-cache -fv \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*
# 创建meme_generator配置目录并下载资源
RUN mkdir -p /root/.meme_generator \
    && cd /tmp \
    && git clone https://github.com/MemeCrafters/meme-generator-rs.git \
    && cp -r meme-generator-rs/resources/ /root/.meme_generator/ \
    && rm -rf meme-generator-rs

RUN sed -i 's/\r$//' /memes/entrypoint.sh
RUN chmod +x /memes/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/memes/entrypoint.sh"]

CMD nb orm upgrade ; nb run
