FROM python:2.7.12-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git bash wget sed nano

WORKDIR /usr/src/app
VOLUME ["/usr/src/app/configs", "/usr/src/app/web"]

ARG timezone=Etc/UTC
RUN echo $timezone > /etc/timezone \
    && ln -sfn /usr/share/zoneinfo/$timezone /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

RUN cd /tmp && wget http://pgoapi.com/pgoencrypt.tar.gz \
    && tar zxvf pgoencrypt.tar.gz \
    && cd pgoencrypt/src \
    && make \
    && cp libencrypt.so /usr/src/app/encrypt.so \
    && cd /tmp \
    && rm -rf /tmp/pgoencrypt*

ENV LD_LIBRARY_PATH /usr/src/app

COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app

ENTRYPOINT ["python", "pokecli.py"]
