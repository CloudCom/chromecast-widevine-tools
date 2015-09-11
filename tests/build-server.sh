#!/bin/bash

# download whatever code is needed

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
  echo -e "Building test staging area...\n\n";
  mkdir -p $STAGING
  chmod 0777 $STAGING
fi

if [ ! -e $STAGING/current ]; then
  echo -e "Downloading latest chromecast OTA...\n\n";

  UPD_XML=$(echo "$UPDATE_DATA" | curl -s $UPDATE_URL -d @- -H 'Content-type: text/xml')
  echo -e "$UPD_XML\n\n"

  UPD_DISPLAYVERSION=$(echo "$UPD_XML" | xmllint --xpath 'string(//@DisplayVersion)' -)
  UPD_CODEBASE=$(echo "$UPD_XML" | xmllint --xpath 'string(//@codebase)' -)
  UPD_SIZE=$(echo "$UPD_XML" | xmllint --xpath 'string(//@size)' -)
  echo -e "Download version $UPD_DISPLAYVERSION from $UPD_CODEBASE\n\n"

  UPD_CODEBASE_OUT=$STAGING/$(basename $UPD_CODEBASE)

  mkdir -p $STAGING
  # wget --continue $UPD_CODEBASE -O $UPD_CODEBASE_OUT

  # unzip $UPD_CODEBASE_OUT -d $STAGING/$UPD_DISPLAYVERSION
  # unsquashfs -d $STAGING/$UPD_DISPLAYVERSION-system $STAGING/$UPD_DISPLAYVERSION/system.img

  # CPIO_OFFSET=`binwalk $STAGING/$UPD_DISPLAYVERSION/boot.img | grep 'gzip compressed data' | cut -d' ' -f1`
  # dd if=$STAGING/$UPD_DISPLAYVERSION/boot.img bs=$CPIO_OFFSET skip=1 of=$STAGING/$UPD_DISPLAYVERSION/boot.cpio.gz
  # mkdir -p $STAGING/$UPD_DISPLAYVERSION-initramfs
  # cd $STAGING/$UPD_DISPLAYVERSION-initramfs && pax -rvzf $STAGING/$UPD_DISPLAYVERSION/boot.cpio.gz

  # echo $UPD_DISPLAYVERSION > $STAGING/current
fi

# build the code