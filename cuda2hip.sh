#!/bin/bash
# run hipify-per inplace of directory
# ./cuda2hip.sh quda

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

for d in $dstdir ; do 
  if [ ! -d $d ] ; then 
    echo "CUDA2HIP error: $d not found"
    continue
  fi
  
  for f in $(find $d -type f -name *.c* -o -name *.h* -o -name *.inl ) ; do
    echo $f
    mv $f ${f}.old
    ${HIPIFY_PERL} ${f}.old > ${f}
    rm ${f}.old
  done

done
