FROM widevine-tools

CMD ./lxc-bootstrap

RUN apt-get update
RUN apt-get install -y libxml2-utils
RUN apt-get install -y zip
RUN apt-get install -y squashfs-tools binwalk pax
RUN apt-get install -y lxc qemu-system-arm qemu-user-static

ADD	.	.