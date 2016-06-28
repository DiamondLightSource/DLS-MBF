/* Simple debug support. */

#include <linux/kernel.h>

#include "debug.h"


void dump_binary(const void *buffer, size_t length)
{
    const uint8_t *dump = buffer;
    char line[128];

    for (size_t a = 0; a < length; a += 16)
    {
        char *l = line;
        l += sprintf(l, "%08zx: ", a);
        for (unsigned int i = 0; i < 16; i ++)
        {
            if (a + i < length)
                l += sprintf(l, " %02x", dump[a+i]);
            else
                l += sprintf(l, "   ");
            if (i % 16 == 7)
                l += sprintf(l, " ");
        }

        l += sprintf(l, "  ");
        for (unsigned int i = 0; i < 16; i ++)
        {
            uint8_t c = dump[a+i];
            if (a + i < length)
                l += sprintf(l, "%c", 32 <= c  &&  c < 127 ? c : '.');
            else
                l += sprintf(l, " ");
            if (i % 16 == 7)
                l += sprintf(l, " ");
        }
        printk(KERN_INFO "%s\n", line);
    }
}
