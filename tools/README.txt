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

    0   System registers: top level hardware control
    1   Control registers: common control interface for DSP control
    2   DSP 0 control
    4   DSP 1 control

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

Hardware control registers

R   0       For version info, currently reads as 0
R   1       Status register
R   1[0]        Set if DSP clock is currently good
R   1[1]        Set during capture to DDR0
R   1[2]        FMC500 VCXO power ok
R   1[3]        FMC500 ADC power ok
R   1[4]        FMC500 DAC power ok
R   1[5]        FMC500 PLL status LD1: VCXO locked
R   1[6]        FMC500 PLL status LD2: VCO locked
R   1[7]        FMC500 temperature alert
RW  2       Control register
RW  2[0]        FMC500 ADC power enable
RW  2[1]        FMC500 DAC power enable
RW  2[2]        FMC500 VCXO power enable
RW  2[3]        FMC500 PLL clkin sel0
RW  2[4]        FMC500 PLL clkin sel1
RW  2[5]        FMC500 PLL sync
RW  3       ADC DCO IDELAY control
W   3[4:0]      IDELAY value
W   3[8]        Enable write to IDELAY, so write number of form 0x1xx
W   3[12]       Enable increment or decrement of IDELAY
W   3[13]       Increment if 1, decrement if 0
W   3[31]       Force reset of ADC PLL
R   3[4:0]      Current IDELAY setting
R   3[31]       Set if ADC PLL not locked
RW  4       FMC500 SPI control


Bank 1 registers
~~~~~~~~~~~~~~~~

General DSP control

RW  0       Captures single clock pulsed events.  Write a bit pattern to reset
            those bits and latch the current state for reading.
    0[0]        Set if DDR0 data error detected
    0[1]        Set if DDR0 address error detected
    0[2]        Set if DDR0 write error detected
W   1       Reserved for strobed control bits
W   2       Initiate capture to DDR0 of requested number of samples
R   2       Returns current DDR0 capture address


Bank 2,3 registers
~~~~~~~~~~~~~~~~~~

W   0[0]    Select DDR0 output: 0 => dummy data, 1 => incoming ADC data


So to capture a full memory bank of ADC data, perform:

    $ ./reg 2 0 1           # Select ADC capture
    $ ./reg 3 0 1           # Select ADC capture
    $ ./reg 1 2 0xFFFFFFE   # (Actually two more writes than selected occur!)


Data capture
------------

The ADC capture mode can be configured by writing to its test mode register:

    $ ./spi 1 0x550 setting

where setting can be one of the following:
   0x00  normal operation
   0x04  alternating checkerboard (1555/2AAA)
   0x07  Alternating 0000/3FFF
   0x0F  ramp output

Capture is triggered by writing the capture length to 1:2:

    $ ./reg 1 2 length

A length of 0xFFFFFFE will fill the entire 2GB buffer.

Data can be read out by reading /dev/amc525_lmbf.0.ddr0


A note on the ADC clock
-----------------------

If the clock changes externally then the internal PLL will unlock and may need
to be manually reset (though I've not yet seen this actually needed).  The clock
unlock status will show in bit 0:3[31] (run command `./reg 0 3`) and can be
reset by setting the same bit (run command `./reg 0 3 0x80000000`).

The easiest way to configure the PLL for passthrough is to uncomment the
labelled lines near the bottom of setup_pll.
