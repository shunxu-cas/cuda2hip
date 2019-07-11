# CUDA到HIP转码
ROCm提供了hipify-perl脚本，实现CUDA代码到HIP代码的转换，其默认路径/opt/rocm/bin/hipify-perl。但是该脚本尚未完善，有不少CUDA代码无法实现转换，而且该脚本更新很慢。

本项目提供一个较完善的CUDA到HIP代码转换的脚本，补充ROCm中转码脚本的不足。

# 相关文件说明
- hipify-perl
  基于ROCm官方提供版本的更新
- cuda2hip.sh
  调用hipify-perl实现文件夹的转换
- cuda2hip.sed 
  供sed调用的脚本文件，补充hipify-perl没有实现的关键字转换
- cuda2hipsed.sh 
  调用hipify-perl和sed脚本实现文件夹的转换

# 使用方法
主体转换用hipify-perl脚本，补充转换用cuda2hip.sed脚本。
应用两个脚本转换之后，转码成功率会很高。

## hipify-perl

```
./hipify-perl <file>
```
`<file>`为待转换的CUDA代码文件名

## cuda2hip.sh

```
./cuda2hip.sh <dir>
```
调用hipify-perl脚本进行代码文件夹内所有代码转换。默认通配`*.c*`和`*.h*`文件（下同）。 
`<dir>`为待转换的CUDA代码所在目录名，可以使用空格输入多个文件目录。

## cuda2hipsed.sh

```
./cuda2hipsed.sh <dir>
```
`<dir>`为待转换的CUDA代码所在目录名，可以使用空格输入多个文件目录。

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
`<files>`为待转换的CUDA代码文件名，可使用Shell通配符。
其中-i表示in-place替换。

- 第二种使用方式
```
find . -type f -name *.c* -o -name *.h* |xargs sed -i -f cuda2hip.sed
```
这个使用借助find查找C/C++和CUDA代码文件，对每个查找到的文件，调用cuda2hip.sed进行转码。