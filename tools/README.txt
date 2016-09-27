Notes on testing LMBF.
======================

Starting and loading
--------------------

The FPGA image is built on pc0073 and is in /scratch/tmp/LMBF/build/fpga.  After
power-cycling the AMC card the FPGA must be loaded.  This is automated by a
makefile rule::

    $ ssh pc0073
    $ cd ~mga83/targetOS/LMBF
    $ make load_fpga

If this is the first loading of the FPGA since the MTCA PC was booted then it
must be rebooted to correctly pick up the PCIe registers, after which the driver
must be installed::

    $ ssh ts-di-lmbf-02
    $ cd ~mga83/targetOS/LMBF
    $ make insmod

Alternatively, if the PC already recognises the module and the driver has been
loaded, the permissions of the (newly recreated) device nodes must be set::

    $ ssh ts-di-lmbf-02
    $ cd ~mga83/targetOS/LMBF
    $ make modperm


Initialising system
-------------------

For the rest of this note I'll assume the following preamble::

    $ ssh ts-di-lmbf-02
    $ cd ~mga83/targetOS/LMBF/tools

After rebooting initialise by running the following scripts::

    $ ./setup_pll
    $ ./setup_adc

To poke around we have two commands to work with: ./reg and ./spi

reg command
-----------

Usage:  reg bank [reg [value]]

Registers are grouped into banks with (at present) 32 registers in each bank.
The currently active banks are:

    0   Memory capture controller
    1   Digital IO card controller
    2   FMC500M controller
    4   Clocking control

reg bank
    Reads entire bank of 32 registers

reg bank reg
    Reads numbered register

reg bank value
    Writes value to register

Below I'll refer to registers as bank:reg, eg 2:0 for the FMC500M SPI register.

spi command
-----------

Usage:  spi device reg [value]

This communicates with the three SPI devices on the FMC card (via register 2:0,
as it happens).  There are three devices:

    0   Clock controller
    1   ADC
    2   DAC


Registers
---------

Bank 0 registers
~~~~~~~~~~~~~~~~

Memory control

R/W 0, 1    Initial value for data pattern
R/W 2, 3    Increment for data pattern

R   4, 5, 6 Data transfer error counters, should NEVER be non zero!
R   7[0]    Set to 1 during writing
R   7[1]    Set to 1 if ADC data selected, 0 if pattern data selected
R   8       Current capture address for writing to DRAM

W   4       When written triggers write of selected number of 64-bit transfers
W   5[0]    Write 1 for ADC capture

So to capture a full memory bank of ADC data, perform:

    $ ./reg 0 5 1           # Select ADC capture
    $ ./reg 0 4 0xFFFFFFE   # (Actually two more writes than selected occur!)


Bank 1 registers
~~~~~~~~~~~~~~~~

Digitial I/O

R   0-31    Returns current value on DIO pins (input or output)

The available DIO outputs are current assigned thus:

    0   Output  PLL DCLKout2
    1   Output  PLL SDCLKout3
    2   Output  PLL VCXO lock (also on top LED)
    3   Output  PLL VCO lock (also on bottom LED)
    4   Input


Bank 2 registers
~~~~~~~~~~~~~~~~

R/W 0       SPI control

R/W 1[0]    Enable VCXO power (doesn't actually seem to do anything
R/W 1[1]    Enable ADC power
R/W 1[2]    Enable DAC power
R/W 1[3]    ADC power down input
R/W 1[4]    DAC reset input
R/W 1[10:8] Miscellaneous unused PLL inputs

R   2[0]    VCXO power status (always 1)
R   2[1]    ADC power status
R   2[2]    DAC power status
R   2[4]    PLL VCXO locked
R   2[5]    PLL VCO locked


Bank 3 registers
~~~~~~~~~~~~~~~~

W   0[4:0]  IDELAY value
W   0[8]    Enable write to IDELAY, so write number of form 0x1xx
W   0[12]   Enable increment or decrement of IDELAY
W   0[13]   Increment if 1, decrement if 0

R   0[4:0]  Current IDELAY setting



Data capture
------------

The ADC capture mode can be configured by writing to its test mode register:

    $ ./spi 1 0x550 setting

where setting can be one of the following:
   0x00  normal operation
   0x04  alternating checkerboard (1555/2AAA)
   0x07  Alternating 0000/3FFF
   0x0F  ramp output

Capture is triggered by writing the capture length to 0:4:

    $ ./reg 0 4 length

A length of 0xFFFFFFE will fill the entire 2GB buffer.

Data can be read out by reading /dev/amc525_lmbf.0.ddr0


A note on the ADC clock
-----------------------

If the clock changes externally then the internal PLL will unlock and will need
to be manually reset.  The clock unlock status will show in bit 2:3[31] (run
command `./reg 2 3`) and can be reset by setting the same bit (run command
`./reg 2 3 0x80000000`).

The easiest way to configure the PLL for passthrough is to uncomment the three
labelled lines near the bottom of setup_pll.


BUGS
----

There's something wrong about how the first 256 bytes are written.  I think
there are two bugs here:

1. It looks as if writes start at offset 0x100, not 0 ... how can that have
changed?  It certainly used to work!

2. Something seems to go wrong with the last burst ... but I can't reliably
reproduce it, it seems that the behaviour changes subtly.

I'm inclined to fear a timing error as well as a logic error.  Ho hum.
