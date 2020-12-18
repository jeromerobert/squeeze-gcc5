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

Roadmap:

* Test `cpu_dispatch` `cpu_specific` on Debian Sid. Done ! Works !
* Test `cpu_dispatch` `cpu_specific` on Windows 10 / MSYS2
* Build clang 11 on Debian Squeeze
* Test `cpu_dispatch` `cpu_specific` on Debian Squeeze
