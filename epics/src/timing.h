/* Simple multi-platform access to high precision CPU cycle counters.  Currently
 * supports modern x86/x86_64 and ARMv7 targets.
 *
 * Note that the reported values can be surprising erratic.  Two natural sources
 * of disturbance are: 1. the CPU cycle is per core, so if a process hops cores
 * between readings the results can be surprising; 2. if the core sleeps or
 * changes frequency then the numbers can be smaller than expected. */

#if defined(__i386)  ||  defined(__x86_64__)
typedef uint64_t cpu_ticks_t;
#elif defined(__ARM_ARCH_7A__)
typedef uint32_t cpu_ticks_t;
#else
#error Unsupported architecture
#endif

static __inline__ cpu_ticks_t get_ticks(void)
{
    cpu_ticks_t ticks;
#if defined(__i386__)
    __asm__ __volatile__("rdtsc" : "=A"(ticks));
#elif defined(__x86_64__)
    uint32_t high, low;
    __asm__ __volatile__("rdtsc" : "=a"(low), "=d"(high));
    ticks = ((uint64_t) high << 32) | low;
#elif defined(__ARM_ARCH_7A__)
    /* The ARM register is PMCCNTR. */
    __asm__ __volatile__("mrc p15, 0, %0, c9, c13, 0" : "=r"(ticks) );
#else
#error oops
#endif
    return ticks;
}
