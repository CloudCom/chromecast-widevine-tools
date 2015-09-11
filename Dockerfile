FROM buildpack-deps:jessie-scm

# TODO should switch to start-server.sh
CMD	bash

RUN apt-get update
RUN apt-get install -y make

ADD	.	/widevine
WORKDIR	/widevine

RUN make

# TODO uncomment after script is complete
# RUN tools/build-server.sh