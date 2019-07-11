#!/bin/bash
# run hipify-per inplace of directory
# ./cuda2hipsed.sh quda

if [ $# -gt 0 ]; then
 dstdir="$*"
else
 dstdir="."
fi

HIPIFY_PERL=`pwd`/hipify-perl
if [ ! -f ${HIPIFY_PERL} ]; then
  if ! which hipify-perl >/dev/null ; then
    echo "CUDA2HIP error: hipify-perl not found"
    exit 1
  fi
  echo "CUDA2HIP warning: use hipify-perl in system"
fi

CUDA2HIP=`pwd`/cuda2hip.sed
if [ ! -f ${CUDA2HIP} ]; then
  echo "CUDA2HIP error: cuda2hip.sed not found"
  exit 1
fi

for d in $dstdir ; do 
  if [ ! -d $d ] ; then 
    echo "CUDA2HIP error: $d not found"
    continue
  fi

  for f in $(find $d -type f -name *.c* -o -name *.h*) ; do
    echo $f
    mv $f ${f}.old
    ${HIPIFY_PERL} ${f}.old > ${f}
    sed -i -f ${CUDA2HIP} ${f}
    rm ${f}.old
  done
  
done
