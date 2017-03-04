#include <stdio.h>
#include <stdlib.h>
#include "flasher.h"

int main(int argc, char **argv) {

  if (!argv[1]) {
    printf("No argument\n");
    return 1;
  }
  char *fname = argv[1];

  FILE *f = fopen(fname, "r");

  char store[MAX_WORD_SIZE];
  printf("Lyrics: ");
  fflash_str(f, 0.05, "l");
  printf("\n");
  fclose(f);

  return 0;

}

