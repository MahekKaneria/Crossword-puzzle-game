/* Purpose: Crossword Puzzle
 * Author: Mahekkumar Kaneria
 * References: https://www.geeksforgeeks.org/solve-crossword-puzzle/
 */

#include "lab14.h"

int main(int argc, char *argv[]) {
    if (argc != 5) {
        return 1;
    }
    char *dictionary_name = argv[1], *crossword_name = argv[2];
    int num_sol = atoi(argv[3]), num_words = atoi(argv[4]);


    // handle files
    int n;
    FILE *fp_cw = fopen(crossword_name, "r");
    if (fscanf(fp_cw, "%d", &n) < 1 || n <= 0) {
        return 1;
    }

    char crossword[n][n];
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (fscanf(fp_cw, " %c", &crossword[i][j]) < 1) {
                return 1;
            }
        }
    }
    fclose(fp_cw);

    FILE *fp_words = fopen(dictionary_name, "r");
    char *words[num_words];
    for (int i = 0; i < num_words; i++) {
        char temp[MAX_LEN];
        if (fscanf(fp_words, "%s", temp) < 1) {
            return 1;
        }
        words[i] = malloc(strlen(temp) + 1);   // '\0'
        strcpy(words[i], temp);
    }
    fclose(fp_words);


    system("mkdir Solutions");
    solve(0, n, words, crossword, num_sol, num_words);
    destroy_words(words, num_words);

    return 0;
}
