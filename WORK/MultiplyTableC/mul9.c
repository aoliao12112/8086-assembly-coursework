#include <stdio.h>

static void print_table(void)
{
    int row;
    int column;

    for (row = 9; row >= 1; --row)
    {
        for (column = 1; column <= row; ++column)
        {
            printf("%d*%d=%d  ", row, column, row * column);
        }
        putchar('\n');
    }
}
int main(void)
{
    puts("The 9mul9 table:");
    print_table();
    return 0;
}
