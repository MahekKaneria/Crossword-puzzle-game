#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX_LEN 100

void solve(int i, int n, char *words[], char crossword[][n], int num_sol, int num_words);
void check_vertical(int row, int col, int n, char *current_word, char crossword[][n]);
void check_horizontal(int row, int col, int n, char *current_word, char crossword[][n]);
void copy_matrix(int n, char original[][n], char copy[][n]);
void output_crossword(FILE *fp, int n, char crossword[][n]);
void destroy_words(char *words[], int num_words);
bool is_finish(int n, char crossword[][n]);
