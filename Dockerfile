FROM ubuntu:latest

WORKDIR /app

RUN apt-get update &&\
    apt-get install \
    sudo nano


CMD tail -f /var/log/apt/history.log