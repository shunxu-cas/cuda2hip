#!/usr/bin/sed -f
#Code porting for CUDA to HIP
#
#./cuda2hip.sed *files*
#sed -i -f cuda2hip.sed *files*
#find . -type f -name *.c* -o -name *.h* -o -name *.inl|xargs sed -i -f cuda2hip.sed
#
#Scripted by Shun Xu
#Ref https://github.com/ROCm-Developer-Tools/HIP

###Remove header files
s|^#include <cuda.h>|//&|
s|^#include <curand_kernel.h>|//&|

###CUDA
#General
s|__CUDA_ARCH__|__HIP_DEVICE_COMPILE__|g
s|cudaResult|hipResult|g

#HIP/hipify-clang/src/CUDA2HIP_Driver_API_functions.cpp
#不支持！
s|cuMemcpy2DAsync|hipMemcpy2DAsync|g

#hipify-clang/src/CUDA2HIP_Driver_API_types.cpp
#部分类似
s|cudaMemoryType|hipMemoryType|g

#cuGetErrorString不类似 hipify-clang/src/CUDA2HIP_Driver_API_functions.cpp
s|cuGetErrorString|hipGetErrorString|g

#cuGetErrorName(res, &msg)换成msg=hipGetErrorName(res)
s|cuGetErrorName|hipGetErrorName|g

#Texture
s|cudaCreateTexture|hipCreateTexture|g
s|cudaDestroyTexture|hipDestroyTexture|g
s|cudaTexture|hipTexture|g
s|cudaGetTexture|hipGetTexture|g

#CUpointer_attribute
s|CUpointer_attribute attribute\[|hipPointerAttribute_t attribute;//\[|g
s|CUpointer_attribute attributes\[|hipPointerAttribute_t attributes;//\[|g

#Event
s|cudaIpcEvent|hipIpcEvent|g

###CUDA libraries
s|CUFFT|HIPFFT|g
s|cub::|hipcub::|g