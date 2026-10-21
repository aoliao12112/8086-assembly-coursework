#include <stdio.h>

int main(void)
{
    char ch = 'a';
    int row;
    int col;

    for (row = 0; row < 2; row++)
    {
        for (col = 0; col < 13; col++)
        {
            putchar(ch);
            putchar(' ');
            ch++;
        }

        putchar('\n');
    }

    return 0;
}