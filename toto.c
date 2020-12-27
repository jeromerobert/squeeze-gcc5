#include <math.h>
#include <stdlib.h>
#include <stdio.h>

static void func(double * restrict x, double* restrict y, double* restrict z) {
  for(int i = 0; i < 8; i++) {
    z[i] += x[i] + y[i];
  }
}

__attribute__((cpu_dispatch(generic, sandybridge, skylake, skylake_avx512)))
void func2(double * restrict x, double* restrict y, double* restrict z);

__attribute__((cpu_specific(generic, sandybridge, skylake, skylake_avx512)))
void func2(double * restrict x, double* restrict y, double* restrict z) {
  func(x, y, z);
  func(x, y, z);
  func(x, y, z);
  func(x, y, z);
}

__attribute__((noinline))
void func3(double * restrict x, double* restrict y, double* restrict z) {
  func2(x, y, z);
  func2(x, y, z);
  func2(x, y, z);
  func2(x, y, z);
}

void print_hello_word_(void);

int main(int argc, char * argv[]) {
  double v = atof(argv[1]);
  double v1 = cos(v);
  double v2 = sin(v);
  double x[] = {v1, v2, v1, v2, v, v, v, v};
  double y[] = {v1, v2, v1, v2, v, v, v, v};
  double z[] = {0, 0, 0, 0, 0, 0, 0, 0};
  for(int i = 0; i < v; i++) {
    func3(x, y, z);
  }
  double r = 0;
  for(int i = 0; i < 8; i++) {
    r += z[i];
  }
  printf("%g\n", r);
  print_hello_word_();
}
