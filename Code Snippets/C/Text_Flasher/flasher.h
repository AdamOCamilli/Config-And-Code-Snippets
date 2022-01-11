#ifndef FLASHER_H
#define FLASHER_H

const int MAX_WORD_SIZE;

int fstore_str(FILE *f, char *s);
void fflash_str(FILE *f, float delay, char *store);
void flash(char *buf, int buf_size, float delay);

#endif
