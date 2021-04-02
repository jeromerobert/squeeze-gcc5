// gcc -march=native -Ofast cexptest.c -lm
#include <stdio.h>
#include <complex.h>
#include <math.h>
#include <x86intrin.h>

inline static double complex mycexp(double complex c) {
    return exp(creal(c)) * (cos(cimag(c)) + I * sin(cimag(c)));
}

inline static void f(double complex * restrict a, int n) {
    for(int i = 0; i < n; i++) {
#ifdef MYCEXP
        a[i] = mycexp(I * a[i]) / a[i];
#else
        a[i] = cexp(I * a[i]) / a[i];
#endif
    }
}

int main(int argc, char * argv[]) {
  int size = 256*1024/16;
  double complex buf[size];
  int niter = 1000;
  long long time = 0;
  for(int k = 0; k < niter; k++) {
    for(int i = 0; i < size; i++)
      buf[i] = (1e-2 + 3e-2 * I) * (i+1.) / (k + 1.);
    long long start = __rdtsc();
    f(buf, size);
    long long end = __rdtsc();
    //printf("%lld\n", (end-start)/size);
    time += end-start;
  }

  double complex sum = 0;
  for(int i = 0; i < size; i++)
    sum += buf[i];
  printf("%g %g %lld\n", creal(sum), cimag(sum), time/size/niter);
}
