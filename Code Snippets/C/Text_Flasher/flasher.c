#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
#include <limits.h>

const int MAX_WORD_SIZE = 100;

/* Return length of the next word (string until a space) that appears in a text file, and
 * store it into given string.
 * Essentially fgets() but it stops at any space instead of just newlines and EOFs,
 * and returns the length of the string instead of the string itself.
 */
int fstore_str(char *store, int store_size, FILE *f) {
  int length = 0;
  char temp;

  // First clear for storage
  memset(store, 0, store_size);
  
  while(!isspace(temp = fgetc(f)) && length <= store_size) {
    store[length] = temp;
    length++;
  } return length;

}

/* Iterates through file, printing every string and then backspacing so as to 
 * overwrite it when printing next string. Has a specified time delay (in seconds) to produce
 * a flashing effect.
 *
 * In default mode ("d") acts as described above
 * In line mode ("l") prints an entire line from file and then overwrites it
 * In whole mode ("w") prints entire file line by line and then overwrites it
 *
 * @param f A text file
 * @param delay Delay in seconds between flashes
 */
void fflash_str(FILE *f, float delay, char *mode) {
  char buf[MAX_WORD_SIZE];
  
  // Default mode
  if (!strcmp(mode,"d")) {
    int i,j,k,prev_i;
    while((i = fstore_str(buf,MAX_WORD_SIZE,f))) { // Get next word from file and its length
      printf("%s", buf);
      for(j = i; prev_i > j; j++) // Make sure we overwrite all characters of previous word
	printf(" ");
      usleep(1000000 * delay); // usleep takes microseconds
      fflush(stdout);
      if (prev_i > i) k = prev_i;
      else k = i;
      for(j = 0; j < k; j++) // Move console cursor to start of word we just output to console
	printf("\b");
      prev_i = i;
    }
  } // Line mode
  else if (!strcmp(mode,"l")) {
    int i, total = 0, end_reached = 0;

    while (!end_reached) {
      // If any words were just overwritten, get back to start of the line
      for (int n = 0; n < total; n++)
	printf("\b");
      
      // Reset total
      total = 0;
      // Print line word by word with delay seconds in between prints
      while ((i = fstore_str(buf,MAX_WORD_SIZE,f)) != '\n' && i != EOF) {
	printf("%s ", buf);
	total += i + 1; // +1 to account for next space
	usleep(1000000 * delay); // usleep takes microseconds
      }
   
      total -= 1; // Last newline/EOF not output, therefore not counted for backspacing
      fflush(stdout); 
      
      // Because newline/EOF was not output, we remain on the line we just output on.
      // Now we will backspace the cursor to the start to overwrite the entire line we just typed
      for (int n = 0; n < total; n++)
	printf("\b");
      for (int n = 0; n < total; n++)
	printf(" ");
      
      // Now we are ready to repeat process if not at end of file
      if (i == EOF)
	end_reached++;
    }
  }
}

/* Iterates through a buffer, printing every non-space and non-EOF char and then 
 * backspacing to overwrite it with a specified time delay (in seconds) for a flashing effect.
 */
void flash(char *buf, int buf_size, float delay) {
  char temp;
  int i;
  for (i = 0; i < buf_size; i++) { // Get char from buffer and output it if non-space
    temp = buf[i];
    if (!isspace(temp)) {
      printf("%c",temp);
      usleep(1000000 * delay);
      if (i + 1 < buf_size)
	printf("\b"); // Now next printed char will overwrite this one
    }
    fflush(stdout); // Make sure to flush output buffer for smooth output on next iteration
  }
}

