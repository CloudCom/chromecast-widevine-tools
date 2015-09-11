#!/bin/bash

# download whatever code is needed
yellow="\033[1;33m"
green="\033[0;32m"
red="\033[0;31m"
NC="\033[0m"

STAGING="$(pwd)/staging"

UPDATE_URL='https://tools.google.com/service/update2'
UPDATE_DATA=$(cat<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<o:gupdate xmlns:o="http://www.google.com/update2/request" version="GoogleTvEureka-0.1.0.0" updaterversion="GoogleTvEureka-0.1.0.0" protocol="2.0" ismachine="1">
    <o:os version="3.0.8" platform="Linux" sp=""></o:os>
    <o:app appid="{45ab3f62-be86-44be-9799-faa6a1229396}" version="12940" lang="en-US" track="stable-channel" board="eureka-b3"
        hardware_class="">
        <o:updatecheck targetversionprefix=""></o:updatecheck>
    </o:app>
</o:gupdate>
EOF
)

if [ ! -d $STAGING ]; then
  printf "${yellow}Building test staging area...${NC}\n\n";
  mkdir -p $STAGING
  chmod 0777 $STAGING
  printf 
fi

if [ ! -e $STAGING/current ]; then
  printf "${yellow}Fetching latest chromecast OTA version.${NC}\n";

  # fetch the xml file that contains information on the latest OTA
  UPD_XML=$(echo "$UPDATE_DATA" | curl -s $UPDATE_URL -d @- -H 'Content-type: text/xml')

  # extract version and where the zip exist 
  UPD_DISPLAYVERSION=$(echo "$UPD_XML" | xmllint --xpath 'string(//@DisplayVersion)' -)
  UPD_CODEBASE=$(echo "$UPD_XML" | xmllint --xpath 'string(//@codebase)' -)
  printf "${green}Version ${UPD_DISPLAYVERSION} avaliable at ${UPD_CODEBASE}.${NC}\n\n";

  UPD_CODEBASE_OUT=$STAGING/$(basename $UPD_CODEBASE)
  mkdir -p $STAGING

  printf "${yellow}Downloading into ${UPD_CODEBASE_OUT} now...${NC}\n"
  curl -# -L $UPD_CODEBASE -o $UPD_CODEBASE_OUT

  unzip $UPD_CODEBASE_OUT -d $STAGING/version
  
  # extract the entire filesystem image into directory
  unsquashfs -d $STAGING/system $STAGING/version/system.img

  # looking for any gzip file in the image and extracts it.
  CPIO_OFFSET=`binwalk $STAGING/version/boot.img | grep 'gzip compressed data' | cut -d' ' -f1`

  dd if=$STAGING/version/boot.img bs=$CPIO_OFFSET skip=1 of=$STAGING/version/boot.cpio.gz
  mkdir -p $STAGING/initramfs
  cd $STAGING/initramfs && pax -rvzf $STAGING/version/boot.cpio.gz

  echo $UPD_DISPLAYVERSION > $STAGING/current
  rm -rf $UPD_CODEBASE_OUT
fi

if [ ! -e $STAGING/current ]; then
  printf "${red}Something went wrong, cannot find local OTA filesystem.${NC}"
  exit 1;
fi

# TODO: validate that we don't need this

# KEY=$STAGING/lxc-key
# if [ ! -e $KEY ]; then
#   echo -e "Generating RSA key for container ...\n\n"
#   ssh-keygen -t rsa -f $KEY -N ""
#   chmod 0774 $KEY
# fi

# build the code

