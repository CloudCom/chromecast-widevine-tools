FROM buildpack-deps:jessie-scm

CMD	bash

RUN apt-get update
RUN apt-get install -y make

ADD	.	/widevine
WORKDIR	/widevine

RUN make