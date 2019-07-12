# CUDA到HIP转码

## 转码的原理
CUDA是NVIDIA开发的GPU SDK（软件开发框架），主要针对NVIDIA GPU硬件开发，而HIP是AMD开发的GPU SDK，主要是针对AMD GPU硬件开发，同时兼容NVIDIA GPU硬件上的开发。试想AMD为何会如此雄心壮志？其实是无奈之举。显然当今CUDA的生态处于绝对优势（dominant），AMD要想迎头赶上，必须兼容CUDA。如何实现兼容CUDA？答案就是利用HIP。

HIP（Heterogeneous-Computing Interface for Portability）实际上就是构造异构计算的接口，一方面对接AMD HCC(Heterogeneous Compute Compiler)，另一方面对接CUDA NVCC。HIP位于HCC和NVCC的上层（或者说在HC和CUDA的上层），HIP的API接口与CUDA API接口类似，但不完全相同。CUDA代码需要通过转码改写为HIP形式才可以在AMD GPU上编译运行，AMD编译环境称为ROCm，提供基于Clang和LLVM开发的编译器HCC（实际上命令行hcc就是alias到clang），我们都知道Clang+LLVM是一个开源的编译器框架，除了支持C/C++编译，也支持[CUDA的编译](https://llvm.org/docs/CompileCudaWithLLVM.html#compiling-cuda-code)。AMD将Clang+LLVM进行扩展形成HCC，以支持AMD GPU编译。实际上在AMD平台，HIP是底层调用HCC编译器实现编译的（一种方式）。

## 转码的实现
如果你留意，可以发现ROCm的HIP项目中提供了一个[hipify-clang](https://github.com/ROCm-Developer-Tools/HIP/tree/master/hipify-clang)的工具。这个hipify-clang工具是基于编译器的词法和语义，理论上是最可靠的一种代码转换方式。因为字面意思的文本转换难以区分API语义，如很难分别是函数名、参数名还是include头文件名等。

hipify-clang从根本上可以解决CUDA到HIP的转码，但不等于说没有困难，困难在于CUDA的版本很多，各版本之间也有不兼容的API问题，而且CUDA少量函数或变量名，在HIP底层并没有实现对应体。

但总的来说，AMD的伙计们还是很给力，不断在更新hipify-clang，也支持最新CUDA 10.1的API转换。基于hipify-clang工具还可以生成perl转码的map文件或python转码的map文件，这里的map文件实质就是转码函数或变量名的映射代码行。一般hipify-clang是随着ROCm环境一起安装的，没法及时更新。导致hipify-clang的新功能没法应用。

HIP项目的[bin目录](https://github.com/ROCm-Developer-Tools/HIP/tree/master/bin)中提供了一个名为hipify-perl的可执行的脚本，借助perl语言定义了CUDA到HIP转码的主体框架以及转换名称的map内容，这个map内容实际上是由于hipify-clang工具生成。更新了hipify-clang工具，也应该更新hipify-perl脚本。但hipify-clang工具需要Clang+LLVM的SDK环境，这是一个较复杂的开发软件环境，一般用户难以驾驭，导致编译hipify-clang有困难。

本项目提供一套较完善的CUDA到HIP代码转换的工具，内置了及时更新版本的hipify-perl脚本，同时提供部分脚本补充hipify-clang和hipify-perl转码的不足。

# 已提交issue
- [#1221](https://github.com/ROCm-Developer-Tools/HIP/issues/1221) 路径符字符串替换时错误。已解决。

# 相关文件说明
- hipify-perl
  基于hipify-clang最新map内容的版本
- hipify-cmakefile
  处理cmake文件(如CMakeList.txt)转码的脚本
- cuda2hip.sh
  调用hipify-perl实现文件夹的转码
- cuda2hip.sed 
  供sed调用的脚本文件，补充hipify-perl没有实现的关键字转码
- cuda2hipsed.sh 
  调用hipify-perl和sed脚本实现文件夹的转码

# 使用方法
CUDA到HIP转码通常基于hipify-clang或hipify-perl。
- 直接使用hipify-clang进行代码转换，理论上hipify-clang是最准确的转码方式，但是它基于编译过程，对软件编译头文件有强烈依赖，容易导致编译过程中断，对转码产生一定影响。
- 还有一种折中的办法，是使用hipify-clang的输出map更新hipify-perl脚本。先用hipify-perl脚本进行主体转换，再用cuda2hip.sed脚本补充转换。应用这两个脚本转换之后，转码成功率相对高些。

## hipify-clang
```
./hipify-clang --help
./hipify-clang --cuda-path=/usr/local/cuda-10.0 -I /usr/local/cuda-10.0/samples/common/inc lib/*.cu
```
hipify-clang是基于Clang+LLVM SDK编译的二进制可执行文件。需要在Clang+LLVM的环境下编译获得，这个环境可以是LLVM官方版本，也可以是ROCm下LLVM分支版本（主要使用Clang前端API区别不大）。这里的CUDA头文件版本，需要与编译Clang时的一致，-I指定编译过程中搜索的include头文件目录，可能需要指定多个路径，便于hipify-clang对代码的扫描-编译-转码过程顺利通过。

## hipify-perl

```
./hipify-perl <file>
```
`<file>`为待转换的CUDA代码文件名

## cuda2hip.sh

```
./cuda2hip.sh <dir>
```
调用hipify-perl脚本进行文件夹内所有代码转换。默认通配`*.c*`、`*.h*`和`*.inl`文件（下同）。 
`<dir>`为待转换的CUDA代码所在目录名，可以使用空格隔空，输入多个文件目录名。

## cuda2hip.sed

- 第一种使用方式
```
./cuda2hip.sed <files>
```
`<files>`为待转换的CUDA代码文件名，可使用Shell通配符。
结果输出到标准输出端。

- 第二种使用方式
```
sed -i -f cuda2hip.sed <files>
```
`<files>`为待转换的CUDA代码文件名，可使用Shell通配符。`-i`表示in-place替换。

- 第三种使用方式
```
find . -type f -name *.c* -o -name *.h* -o -name *.inl |xargs sed -i -f cuda2hip.sed
```
这里借助find查找C/C++和CUDA代码文件，对每个查找到的文件调用cuda2hip.sed进行转码。

## cuda2hipsed.sh

```
./cuda2hipsed.sh <dir>
```
调用hipify-perl和cuda2hip.sed脚本进行文件夹内所有代码转换。默认通配`*.c*`、`*.h*`和`*.inl`文件。`<dir>`为待转换的CUDA代码所在目录名，可以使用空格输入多个文件目录。