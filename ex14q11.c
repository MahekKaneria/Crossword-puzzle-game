#include "lab14.h"

int possible_ways = 0;


void solve(int i, int n, char *words[], char crossword[][n], int num_sol, int num_words) {
    // base cases
    if (is_finish(n, crossword)) {
        possible_ways++;
        char filename[30];
        sprintf(filename, "Solutions/sol%d.txt", possible_ways);
        FILE *fp = fopen(filename, "w");
        output_crossword(fp, n, crossword);
        fclose(fp);
        if (possible_ways >= num_sol) {
            destroy_words(words, num_words);
            exit(0);
        }
        return;
    }

    if (i >= num_words) {
        return;
    }

    // inductive cases
    char *current_word = words[i];
    int max_possible = n-strlen(current_word);

    // try all vertical options
    for (int col = 0; col < n; col++) {
        for (int row = 0; row <= max_possible;) {
            char crossword_new[n][n];
            copy_matrix(n, crossword, crossword_new);
            check_vertical(row, col, n, current_word, crossword_new);

            if (crossword_new[0][0] != '1') {
                solve(i+1, n, words, crossword_new, num_sol, num_words);
            }

            // Jump to the next spot to fill (maybe there'll be some disjoint?)
            while (row <= max_possible && crossword[row][col] != '*') {
                row++;
            }
            while (row <= max_possible && crossword[row][col] == '*') {
                row++;
            }
        }
    }

    // try all horizontal options
    for (int row = 0; row < n; row++) {
        for (int col = 0; col <= max_possible;) {
            char crossword_new[n][n];
            copy_matrix(n, crossword, crossword_new); 
            check_horizontal(row, col, n, current_word, crossword_new);

            if (crossword_new[0][0] != '1') {
                solve(i+1, n, words, crossword_new, num_sol, num_words);
            }

            while (col <= max_possible && crossword[row][col] != '*') {
                col++;
            }
            while (col <= max_possible && crossword[row][col] == '*') {
                col++;
            }
        }
    }

    // try without the current word
    solve(i+1, n, words, crossword, num_sol, num_words);

    return;
}


bool is_finish(int n, char crossword[][n]) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (crossword[i][j] == '0') {
                return false;
            }
        }
    }
    return true;
}


void check_vertical(int row, int col, int n, char *current_word, char crossword[][n]) {
    for (int i = 0; i < strlen(current_word); i++) {
        if (crossword[row+i][col] == '0' || crossword[row+i][col] == current_word[i]) {
            crossword[row+i][col] = current_word[i];
        }
        else {
            crossword[0][0] = '1';
            return;
        }
    }
    if (row+strlen(current_word) < n && crossword[row+strlen(current_word)][col] != '*') {
        crossword[0][0] = '1';
        return;
    }

    return;
}   


void check_horizontal(int row, int col, int n, char *current_word, char crossword[][n]) {
    for (int i = 0; i < strlen(current_word); i++) {
        if (crossword[row][col+i] == '0' || crossword[row][col+i] == current_word[i]) {
            crossword[row][col+i] = current_word[i];
        }
        else {
            crossword[0][0] = '1';
            return;
        }
    }
    if (col+strlen(current_word) < n && crossword[row][col+strlen(current_word)] != '*') {
        crossword[0][0] = '1';
        return;
    }

    return;
}   


void copy_matrix(int n, char original[][n], char copy[][n]) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            copy[i][j] = original[i][j];
        }
    }

    return;
}


void output_crossword(FILE *fp, int n, char crossword[n][n]) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            fprintf(fp, "%c ", crossword[i][j]);
        }
        fprintf(fp, "\n");
    }

    return;
}


void destroy_words(char *words[], int num_words) {
    for (int i = 0; i < num_words; i++) {
        free(words[i]);
    }

    return;
}
