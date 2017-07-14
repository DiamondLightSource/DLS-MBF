/* Detector control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "common.h"
#include "hardware.h"

#include "detector.h"


/* Called before arming the detector. */
void prepare_detector(int channel)
{
    printf("prepare_detector %d\n", channel);
}


error__t initialise_detector(void)
{
    return ERROR_OK;
}
