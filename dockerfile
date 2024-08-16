# build stage
FROM python:3.10-slim-bookworm AS builder

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
FROM python:3.10-slim-bookworm

# retrieve packages from build stage
ENV PYTHONPATH=/pkgs
# copy files
WORKDIR /memes
COPY memes_remote .env entrypoint.sh pyproject.toml /memes/
COPY --from=builder /tmp/__pypackages__/3.10/lib /pkgs
COPY --from=builder /tmp/__pypackages__/3.10/bin/* /bin/
COPY ./fonts/* /usr/share/fonts/

# install deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales fontconfig fonts-noto-color-emoji gettext \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && fc-cache -fv \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*
RUN meme download
RUN chmod +x /memes/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/memes/entrypoint.sh"]

CMD nb run
