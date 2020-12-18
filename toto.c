static void func(double * restrict x, double* restrict y, double* restrict z) {
  for(int i = 0; i < 8; i++) {
    z[i] += x[i] + y[i];
  }
}

__attribute__((cpu_specific(generic, skylake, skylake_avx512)))
void func2(double * restrict x, double* restrict y, double* restrict z) {
  func(x, y, z);
  func(x, y, z);
  func(x, y, z);
  func(x, y, z);
}

void func3(double * restrict x, double* restrict y, double* restrict z) {
  func2(x, y, z);
  func2(x, y, z);
  func2(x, y, z);
  func2(x, y, z);
}
