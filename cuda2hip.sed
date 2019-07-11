#!/usr/bin/sed -f
#Code porting for CUDA to HIP
#
#./cuda2hip.sed *files*
#sed -i -f cuda2hip.sed *files*
#find . -type f -name *.c* -o -name *.h* |xargs sed -i -f cuda2hip.sed
#
#Scripted by Shun Xu
#Supported by Yijiang Bi, Yibo Yang, Ming Gong, Yi Xiao.
#version 0.1,  2019.7.11

###Remove header files
s|^#include <cuda.h>|//&|
s|^#include <curand_kernel.h>|//&|

###CUDA
#General
s|CUdeviceptr|hipDeviceptr_t|g
s|cudaResource|hipResource|g
s|cudaHostRegister|hipHostRegister|g
s|cudaReadMode|hipReadMode|g
s|cudaChannel|hipChannel|g
s|cudaResult|hipResult|g
s|cudaRuntimeGetVersion|hipRuntimeGetVersion|g
s|cudaIpc|hipIpc|g
#Memory
s|cudaHostRegisterPortable|hipHostRegisterPortable|g
s|CU_MEMORYTYPE_UNIFIED|hipMemoryTypeUnified|g
s|CU_MEMORYTYPE_ARRAY|hipMemoryTypeArray|g
s|cuMemcpyDtoH|hipMemcpyDtoH|g
s|cuMemcpyHtoD|hipMemcpyHtoD|g
s|cuMemcpyDtoD|hipMemcpyDtoD|g
s|cuMemcpy2DAsync|hipMemcpy2DAsync|g
s|cuMemcpyDtoHAsync|hipMemcpyDtoHAsync|g
s|cuMemcpyHtoDAsync|hipMemcpyHtoDAsync|g
s|cuMemcpyDtoDAsync|hipMemcpyDtoDAsync|g
s|cudaMemcpyToSymbol|hipMemcpyToSymbol|g
s|cudaMemoryType|hipMemoryType|g
s|cudaMemcpyAsync|hipMemcpyAsync|g
s|cudaMemcpy2DAsync|hipMemcpy2DAsync|g
s|cudaMemset2D|hipMemset2D|g
s|CUmemorytype|hipMemoryType|g
s|cuMemFree|hipFree|g
s|cuMemAlloc|hipMalloc|g
s|cudaMemcpyType|hipMemcpy|g
s|CU_MEMORYTYPE_HOST|hipMemoryTypeHost|g
s|CU_MEMORYTYPE_DEVICE|hipMemoryTypeDevice|g
s|CUDA_MEMCPY2D|hip_Memcpy2D|g
#CUpointer_attribute
s|CUpointer_attribute attribute\[|hipPointerAttribute_t attribute;//\[|g
s|CUpointer_attribute attributes\[|hipPointerAttribute_t attributes;//\[|g
#Stream
s|cuStreamWaitEvent|hipStreamWaitEvent|g
s|cuStream|hipStream|g 
s|cudaStreamCreateWithPriority|hipStreamCreateWithPriority|g
s|cudaDeviceGetStreamPriorityRange|hipDeviceGetStreamPriorityRange|g
s|CUstream|hipStream_t|g
#Error
s|CUDA_ERROR_FILE_NOT_FOUND|hipErrorFileNotFound|g
s|__CUDA_ARCH__|__HIP_DEVICE_COMPILE__|g
s|CUresult|hipError_t|g
#cuGetErrorString
s|cuGetErrorString(tunable.jitifyError(), &str);|str=hipGetErrorString(tunable.jitifyError());|g
#lib/malloc.cpp
s|cuGetErrorString(error, &string);|string=hipGetErrorString(error);|g
#lib/dslash_policy.cuh
s|cuGetErrorString(cudaStatus, &err_str);|err_str=hipGetErrorString(call);|g
s|cuGetErrorName(error, &str)|str=hipGetErrorName(error)|g
s|cuGetErrorName(res, &msg)|msg=hipGetErrorName(res)|g
s|cuGetErrorName(err, &str)|str=hipGetErrorName(err)|g
s|CUDA_ERROR_NOT_READY|hipErrorNotReady|g
s|CUDA_ERROR_FILE_NOT_FOUND|hipErrorFileNotFound|g
s|CUDA_SUCCESS|hipSuccess|g
#Texture
s|cudaCreateTexture|hipCreateTexture|g
s|cudaDestroyTexture|hipDestroyTexture|g
s|cudaTexture|hipTexture|g
s|cudaGetTexture|hipGetTexture|g
#Event
s|cudaIpcEvent|hipIpcEvent|g
s|cudaEvent|hipEvent|g
s|cudaEventInterprocess|hipEventInterprocess|g
#lib/lattice_field.cpp lib/clover_outer_product.cu lib/extended_color_spinor_utilities.cu
s|hipEventCreate|hipEventCreateWithFlags|g
s|cuCtxSynchronize|hipCtxSynchronize|g

###CUDA libraries
#rand
s|curandState|hiprandState|g
s|curand_|hiprand_|g
#blas
s|cublasStatus_t|hipblasStatus_t|g
s|cublasCget|hipblasCget|g
s|cublasCreate|hipblasCreate|g
s|cublasHandle|hipblasHandle|g
s|cublasDestroy|hipblasDestroy|g
#fft
s|cufft.h|hipfft.h|g
s|cufft|hipfft|g
s|CUFFT|HIPFFT|g
#cub
s|cub::|hipcub::|g
#Complex
s|cuDoubleComplex|hipDoubleComplex|g
s|cuFloatComplex|hipFloatComplex|g
s|cuComplex.h|hip/hip_complex.h|g