* Test clang
* Test gcc > 5
* Test clang `cpu_dispatch` `cpu_specific` and gcc `target_clones`
* Find kernel / libc ifunc prerequisites. DONE: From gcc atttributes documentation:
  *Binutils version 2.20.1 or higher and GNU C Library version 2.11.1 are required to use this feature.*
* Find clang and gcc glibc prerequisites
* Is `target_clones` supported on Windows ? No !
* Is `cpu_dispatch` `cpu_specific` supported on Windows ?
* *GCC must be configured to use GLIBC 2.23 or newer in order to use the `target_clones` attribute.*
* <https://www.reddit.com/r/cpp/comments/hyfhy3/differences_between_old_pre_gcc6_and_newstyle/>
* Is it possible to use clang with gfortran on Windows as on Linux ? (can be tested with msys2)
* <https://llvm.org/docs/CMake.html>
* <https://github.com/llvm-mirror/clang/blob/master/include/clang/Basic/X86Target.def>
* `clang -Ofast -no-integrated-as -Xassembler -adhln -target i686-pc-windows-gnu -S toto.c`
* <https://stackoverflow.com/questions/23248989/clang-c-cross-compiler-generating-windows-executable-from-mac-os-x>
* `clang -v -fuse-ld=lld -L/usr/lib/gcc/x86_64-w64-mingw32/10-win32/ -Ofast -target x86_64-pc-windows-gnu -lgfortran totof.o toto.c`

Roadmap (all DONE)

* Test `cpu_dispatch` `cpu_specific` on Debian Sid.
* Test `cpu_dispatch` `cpu_specific` on Windows 10 / MSYS2
* Build clang 11 on Debian Squeeze.
* Test `cpu_dispatch` `cpu_specific` on Debian Squeeze

Debian squeeze gcc5:

```
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$HOME/gcc/llvm-install \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;libunwind;compiler-rt;lld;polly;openmp;parallel-libs;libclc' \
  -G "Unix Makefiles" ../llvm
```
* Flang and libcxx require gcc >= 7
* `clang -lm -B/usr/local -Ofast toto.c`
