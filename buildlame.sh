##!/bin/bash

if [ $# -eq 0 ]; then
    echo "错误：请指定构建安装的目标目录" >&2  # 输出到标准错误
    echo "如果要使用相对路径请以\$PWD开头" >&2  # --prefix只能接受绝对路径
    exit 1  # 返回非零状态码表示错误
fi
# 一次性清掉旧配置
make distclean 2>/dev/null || true

emconfigure ./configure \
    --prefix=$1     \
    --disable-frontend             \
    --disable-shared --enable-static \
    --disable-decoder --disable-gtktest \
    --enable-nasm=no \
    CFLAGS="-O3 -fPIC"

# 编译 & 安装
emmake make -j$(sysctl -n hw.logicalcpu)
emmake make install

#创建 pc 文件供 pkg-config 使用
mkdir -p $1/lib/pkg-config/
cat > $1/lib/pkgconfig/libmp3lame.pc <<EOF
prefix=$1
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: LAME
Description: MP3 encoding library
Version: 3.100
Libs: -L\${libdir} -lmp3lame
Cflags: -I\${includedir}
EOF
