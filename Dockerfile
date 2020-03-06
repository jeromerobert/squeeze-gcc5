FROM debian:squeeze AS base
RUN echo deb http://archive.debian.org/debian/ squeeze contrib main non-free > /etc/apt/sources.list
RUN apt-get update && apt-get install --force-yes -y --no-install-recommends \
    bzip2 make m4 file pkg-config libexpat1-dev zlib1g-dev gettext \
    openssh-client rsync libbz2-dev libreadline-dev libglu1-mesa-dev man xz-utils patch \
    libxt-dev libxtst6 libxrender1 libxi6 unzip libc6=2.11.3-4 libc-bin=2.11.3-4 perl-modules \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/locale

FROM base as dev
RUN apt-get update

FROM dev AS curl
RUN apt-get install -y --no-install-recommends --force-yes gcc curl
RUN curl -kO https://www.openssl.org/source/openssl-1.1.1c.tar.gz
RUN curl -LO http://deb.debian.org/debian/pool/main/c/curl/curl_7.68.0.orig.tar.gz

RUN sha256sum openssl*.tar.gz
RUN echo "f6fb3079ad15076154eda9413fed42877d668e7069d9b87396d0804fdb3f4c90 " openssl*.tar.gz | sha256sum -c -
RUN tar xf openssl*.tar.gz
WORKDIR openssl-1.1.1c
RUN ./config --prefix=/usr/local --openssldir=/usr/local shared
RUN make -j$(nproc)
RUN make install_sw install_ssldirs
WORKDIR /

RUN sha256sum curl*tar.gz
RUN echo "1dd7604e418b0b9a9077f62f763f6684c1b092a7bc17e3f354b8ad5c964d7358 " curl*tar.gz | sha256sum -c -
RUN tar xf curl*tar.gz
WORKDIR curl-7.68.0
RUN ./configure --disable-static
RUN make -j $(nproc)
RUN make install
RUN rm /usr/local/lib/*.a
RUN strip -p /usr/local/lib/* /usr/local/bin/* || true

FROM dev as gcc
RUN apt-get install -y --no-install-recommends --force-yes g++ curl
RUN curl -LO http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
RUN curl -LO http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
RUN curl -LO http://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz
RUN curl -LO http://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
RUN curl -LO http://mirror.koddos.net/gcc/releases/gcc-5.5.0/gcc-5.5.0.tar.xz

# Binutils
RUN sha256sum binutils*.tar.*
RUN echo "0ab6c55dd86a92ed561972ba15b9b70a8b9f75557f896446c82e8b36e473ee04 " binutils*.tar.* | sha256sum -c -
RUN tar xf binutils*.tar.*
WORKDIR build-binutils
RUN ../binutils*/configure
RUN make -j$(nproc)
RUN make install
WORKDIR /

# GMP
RUN sha256sum gmp*.tar.*
RUN echo "87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912 " gmp*.tar.* | sha256sum -c -
RUN tar xf gmp*.tar.*
WORKDIR build-gmp
RUN ../gmp*/configure
RUN make -j$(nproc)
RUN make install
RUN ldconfig
WORKDIR /

# mpfr
RUN sha256sum mpfr*.tar.*
RUN echo "1d3be708604eae0e42d578ba93b390c2a145f17743a744d8f3f8c2ad5855a38a " mpfr*.tar.* | sha256sum -c -
RUN tar xf mpfr*.tar.*
WORKDIR build-mpfr
RUN ../mpfr*/configure
RUN make -j$(nproc)
RUN make install
RUN ldconfig
WORKDIR /

# mpc
RUN sha256sum mpc*.tar.*
RUN echo "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e " mpc*.tar.* | sha256sum -c -
RUN tar xf mpc*.tar.*
WORKDIR build-mpc
RUN ../mpc*/configure
RUN make -j$(nproc)
RUN make install
RUN ldconfig
WORKDIR /

# gcc
RUN sha256sum gcc*.tar.*
RUN echo "530cea139d82fe542b358961130c69cfde8b3d14556370b65823d2f91f0ced87 " gcc*.tar.* | sha256sum -c -
RUN tar xf gcc*.tar.*
WORKDIR build-gcc
RUN ../gcc*/configure --enable-languages=c,c++,fortran --disable-multilib
RUN make -j$(nproc)
RUN make install
WORKDIR /

# Intermediate image with up to date gcc and curl
FROM base as gcc-curl
COPY --from=gcc /usr/local/ /usr/local/
COPY --from=curl /usr/local/ /usr/local/
RUN echo /usr/local/lib64 >> /etc/ld.so.conf.d/lib64.conf
RUN ldconfig

FROM gcc-curl as python
# python
RUN curl -kLO https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz
RUN sha256sum Python-*.tgz
RUN echo "f22059d09cdf9625e0a7284d24a13062044f5bf59d93a7f3382190dfa94cecde " Python-*.tgz | sha256sum -c -
RUN tar xf *.tgz
WORKDIR Python-2.7.17
RUN ./configure --enable-shared
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN curl -kLO https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install Cython

FROM gcc-curl as cmake
# cmake
RUN curl -kLO https://github.com/Kitware/CMake/releases/download/v3.16.5/cmake-3.16.5.tar.gz
RUN sha256sum cmake-*.tar.gz
RUN echo "5f760b50b8ecc9c0c37135fae5fbf00a2fef617059aa9d61c1bb91653e5a8bfc " cmake-*.tar.gz | sha256sum -c -
RUN tar xf *.tar.gz
WORKDIR cmake-3.16.5
RUN ./bootstrap --parallel=$(nproc)
RUN make -j$(nproc)
RUN make install

FROM gcc-curl as chrpath
# TODO replace chrpath with patchelf
# chrpath
RUN curl -LO http://http.debian.net/debian/pool/main/c/chrpath/chrpath_0.16.orig.tar.gz
RUN sha256sum *.tar.gz
RUN echo "bb0d4c54bac2990e1bdf8132f2c9477ae752859d523e141e72b3b11a12c26e7b " *.tar.gz | sha256sum -c -
RUN tar xf *.tar.gz
WORKDIR chrpath-0.16
RUN ./configure
RUN make -j$(nproc)
RUN make install
RUN find /usr/local

FROM gcc-curl as git
# Git
RUN curl -kLO https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.25.1.tar.xz
RUN sha256sum *.tar.xz
RUN echo "222796cc6e3bf2f9fd765f8f097daa3c3999bb7865ac88a8c974d98182e29f26 " *.tar.* | sha256sum -c -
RUN tar xf *.tar.xz
WORKDIR git-2.25.1
RUN ./configure --prefix=/usr/local
RUN make -j $(nproc)
RUN make NO_INSTALL_HARDLINKS=YesPlease install

FROM gcc-curl as swig
# Swig
RUN curl -kLO https://downloads.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz
RUN sha256sum  *.tar.*
RUN echo "65e13f22a60cecd7279c59882ff8ebe1ffe34078e85c602821a541817a4317f7 " *.tar.* | sha256sum -c -
RUN tar xf *.tar.*
WORKDIR swig-2.0.12
RUN ./configure --without-pcre
RUN make -j $(nproc)
RUN make install

# Autotools
FROM gcc-curl as autotools
RUN curl -LO http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
RUN echo "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969 " autoconf*.tar.* | sha256sum -c -
RUN curl -kLO https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz
RUN echo "988e32527abe052307d21c8ca000aa238b914df363a617e38f4fb89f5abf6260 " automake*.tar.* | sha256sum -c -
RUN curl -kLO https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz
RUN echo "e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3 " libtool*.tar.* | sha256sum -c -
RUN tar xf autoconf*.tar.*
RUN tar xf automake*.tar.*
RUN tar xf libtool*.tar.*
WORKDIR /autoconf-2.69
RUN ./configure
RUN make -j$(nproc)
RUN make install
WORKDIR /automake-1.15.1
RUN ./configure
RUN make -j$(nproc)
RUN make install
WORKDIR /libtool-2.4.6
RUN ./configure
RUN make -j$(nproc)
RUN make install

#hwloc
FROM gcc-curl as hwloc
RUN curl -kLO https://download.open-mpi.org/release/hwloc/v2.1/hwloc-2.1.0.tar.bz2
RUN sha256sum *.tar.*
RUN echo "19429752f772cf68321196970ffb10dafd7e02ab38d2b3382b157c78efd10862 " *.tar.* | sha256sum -c -
RUN tar xf *.tar.*
WORKDIR hwloc-2.1.0
RUN ./configure
RUN make -j$(nproc)
RUN make install

# ffi
FROM gcc-curl as ffi
RUN curl -kLO https://sourceware.org/pub/libffi/libffi-3.3.tar.gz
RUN sha256sum *.tar.*
RUN echo "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056 " *.tar.* | sha256sum -c -
RUN tar xf *.tar.*
WORKDIR libffi-3.3
RUN ./configure --disable-static
RUN make -j$(nproc)
RUN make install

# Intermediate stage for stripping
FROM gcc-curl as allinone-stripped
COPY --from=python /usr/local/ /usr/local/
COPY --from=cmake /usr/local/ /usr/local/
COPY --from=chrpath /usr/local/ /usr/local/
COPY --from=git /usr/local/ /usr/local/
COPY --from=swig /usr/local/ /usr/local/
COPY --from=autotools /usr/local/ /usr/local/
COPY --from=hwloc /usr/local/ /usr/local/
COPY --from=ffi /usr/local/ /usr/local/
RUN find /usr/local ! -name '*.o' -type f -exec sh -c "file -b {} | grep -Eq '^ELF.*, not stripped' && strip {}" \;

# Final stage
FROM gcc-curl as final
COPY --from=allinone-stripped /usr/local /usr/local
