# @file
#   Linux script file to generate UEFI capsules for a sample device
#
# Copyright (c) 2018, Intel Corporation. All rights reserved.<BR>
#
# SPDX-License-Identifier: BSD-2-Clause-Patent
#

COLOR=$1

FMP_CAPSULE_VENDOR=Intel
FMP_CAPSULE_GUID=$2
FMP_CAPSULE_FILE=$COLOR.cap
FMP_CAPSULE_VERSION=0x00000010
FMP_CAPSULE_STRING=0.0.0.16
FMP_CAPSULE_NAME="$COLOR Progress Bar $FMP_CAPSULE_STRING"
FMP_CAPSULE_LSV=0x00000000
FMP_CAPSULE_PAYLOAD=Payload.bin

echo "$COLOR Progress Bar" > $FMP_CAPSULE_PAYLOAD

if [ ! -e "$FMP_CAPSULE_PAYLOAD" ] ; then
  return
fi

if [ -e NewCert.pem ]; then
  #
  # Sign capsule using OpenSSL with a new certificate
  #
  GenerateCapsule \
    --encode \
    -v \
    --guid $FMP_CAPSULE_GUID \
    --fw-version $FMP_CAPSULE_VERSION \
    --lsv $FMP_CAPSULE_LSV \
    --capflag PersistAcrossReset \
    --capflag InitiateReset \
    --signer-private-cert=NewCert.pem \
    --other-public-cert=NewSub.pub.pem \
    --trusted-public-cert=NewRoot.pub.pem \
    -o $FMP_CAPSULE_FILE \
    $FMP_CAPSULE_PAYLOAD

  cp $FMP_CAPSULE_FILE $WORKSPACE/Build/Vlv2TbltDevicePkg/Capsules/NewCert

  rm $FMP_CAPSULE_FILE
fi

#
# Sign capsule using OpenSSL with EDK II Test Certificate
#
GenerateCapsule \
  --encode \
  -v \
  --guid $FMP_CAPSULE_GUID \
  --fw-version $FMP_CAPSULE_VERSION \
  --lsv $FMP_CAPSULE_LSV \
  --capflag PersistAcrossReset \
  --capflag InitiateReset \
  --signer-private-cert=$WORKSPACE/edk2/BaseTools/Source/Python/Pkcs7Sign/TestCert.pem \
  --other-public-cert=$WORKSPACE/edk2/BaseTools/Source/Python/Pkcs7Sign/TestSub.pub.pem \
  --trusted-public-cert=$WORKSPACE/edk2/BaseTools/Source/Python/Pkcs7Sign/TestRoot.pub.pem \
  -o $FMP_CAPSULE_FILE \
  $FMP_CAPSULE_PAYLOAD

cp $FMP_CAPSULE_FILE $WORKSPACE/Build/Vlv2TbltDevicePkg/Capsules/TestCert

rm $FMP_CAPSULE_FILE

rm $FMP_CAPSULE_PAYLOAD
