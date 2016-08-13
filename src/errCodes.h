
void mexprintError(int x);

typedef enum {
  ERR_OK = 0,
  ERR_PLAN,
  ERR_CUFFT,
  ERR_FFT_FORWARD,
  ERR_FFT_INVERSE,
  ERR_MALLOC,
  ERR_COMPAT,
  ERR_FAILSAFE,
  ERR_COPY //added 8/7
} ERR_CODE;

