FROM python:3.9-alpine as backend
ENV PYTHONUNBUFFERED 1
ENV DEBUG 'True'
RUN mkdir /code
WORKDIR /code
# Install application dependencies
COPY requirements.txt .
RUN apk --no-cache add \
        jpeg \
        libffi \
        postgresql-libs \
        openssl \
        postgresql-client \
        && \
    apk --no-cache add \
        --virtual .requirements-build-deps \
        gcc \
        jpeg-dev \
        libffi-dev \
        musl-dev \
        postgresql-dev \
        zlib-dev \
        linux-headers \
        && \
    python3 -m pip install -r requirements.txt --no-cache-dir && \
    apk --purge del .requirements-build-deps

COPY docker/uwsgi.ini /etc/uwsgi/uwsgi.ini

COPY entrypoint.sh /entrypoint.sh
COPY ./src .
RUN chown -R nobody:nogroup /code
RUN python manage.py  collectstatic  --noinput
VOLUME [ "/code/media" ]
EXPOSE 8000
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "uwsgi", "--ini", "/etc/uwsgi/uwsgi.ini" ]
