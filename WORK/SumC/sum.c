#include <stdio.h>

static unsigned int sum_to(unsigned int n)
{
    unsigned int total = 0;
    unsigned int i;

    for (i = 1; i <= n; ++i)
    {
        total += i;
    }

    return total;
}

int main(void)
{
    unsigned int n;

    printf("1 + 2 + ... + 100 = %u\n", sum_to(100));
    printf("Input n (1-100): ");

    if (scanf_s("%u", &n) != 1 || n < 1 || n > 100)
    {
        puts("Input error: n must be in 1..100.");
        return 1;
    }

    printf("1 + 2 + ... + %u = %u\n", n, sum_to(n));
    return 0;
}
