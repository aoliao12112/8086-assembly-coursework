#include <stdint.h>
#include <stdio.h>

#define LIMBS 6
#define BASE 10000U

typedef struct BigNumber
{
    uint16_t limb[LIMBS];
} BigNumber;

static BigNumber fib_a = {{0}};
static BigNumber fib_b = {{1}};
static BigNumber fib_next;

static void advance_fibonacci(void)
{
    uint32_t carry = 0;
    int i;

    for (i = 0; i < LIMBS; ++i)
    {
        uint32_t sum = (uint32_t)fib_a.limb[i]
                     + (uint32_t)fib_b.limb[i]
                     + carry;
        fib_next.limb[i] = (uint16_t)(sum % BASE);
        carry = sum / BASE;
    }

    fib_a = fib_b;
    fib_b = fib_next;
}

static void print_big(const BigNumber *number)
{
    int i = LIMBS - 1;

    while (i > 0 && number->limb[i] == 0)
    {
        --i;
    }

    printf("%u", (unsigned int)number->limb[i]);
    while (--i >= 0)
    {
        printf("%04u", (unsigned int)number->limb[i]);
    }
}

static void print_sequence(unsigned int remaining)
{
    if (remaining == 0)
    {
        return;
    }

    print_big(&fib_a);
    putchar(' ');

    if (remaining > 1)
    {
        advance_fibonacci();
        print_sequence(remaining - 1); /* recursive call */
    }
}

int main(void)
{
    unsigned int n;

    printf("Input n (1-100): ");
    if (scanf_s("%u", &n) != 1 || n < 1 || n > 100)
    {
        puts("Input error: n must be 1..100.");
        return 1;
    }

    puts("Fibonacci sequence:");
    print_sequence(n);
    putchar('\n');
    return 0;
}
