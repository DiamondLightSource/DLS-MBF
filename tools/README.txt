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
RW  2[6]        ADC power down (leave at 0 for normal operation)
RW  2[7]        DAC reset (leave at 0 for normal operation)
RW  2[8]        Enable DAC test data generation
RW  3       ADC DCO IDELAY control
W   3[4:0]      IDELAY value
W   3[8]        Enable write to IDELAY, so write number of form 0x1xx
W   3[12]       Enable increment or decrement of IDELAY
W   3[13]       Increment if 1, decrement if 0
W   3[31]       Force reset of ADC PLL
R   3[4:0]      Current IDELAY setting
R   3[31]       Set if ADC PLL not locked
RW  4       FMC500 SPI control
RW  5,6     DAC test data pattern


Bank 1 registers
~~~~~~~~~~~~~~~~

General DSP control

RW  0       Captures single clock pulsed events.  Write a bit pattern to reset
            those bits and latch the current state for reading.
    0[0]        Set if DDR0 data error detected
    0[1]        Set if DDR0 address error detected
    0[2]        Set if DDR0 write error detected
RW  1       Miscellaneous control
    1[0]        ADC mux: if set then channel 0 has copy of channel 1 ADC data
    1[1]        NCO0 mux: if set then channel 0 has sin data from channel 1
    1[2]        NCO1 mux: if set then channel 0 has sin data from channel 1
W   2       Initiate capture to DDR0 of requested number of samples
R   2       Returns current DDR0 capture address


Bank 2,3 registers
~~~~~~~~~~~~~~~~~~

General register mapping
    0,1     Top level DSP control
    2,3     ADC input control
    4,5     Bunch clock and bunch by bunch configuration
    6       Memory capture control
    7,8     Bunch by bunch FIR control
    9,10    DAC output control
    11-13   Work in progress
    14,15   Unused


W   0       Write single clock pulsed events
    0[0]        Start write to banked registers
    0[1]        Reset bunch by bunch delta event
The following are temporary only:
    0[29]       Reset NCO1 phase
    0[30]       Reset NCO0 phase
    0[31]       Trigger bunch synchronisation
R   0       Read static status bits
RW  1       Capture single clock pulsed events
    1[0]        Set if ADC input threshold exceeded
    1[1]        Set if ADC FIR overflow
    1[2]        Set if ADC min/max/sum accmulator overflow
    1[3]        Set if bunch by bunch motion overflow
    1[4]        Set if FIR overflow in DAC output
    1[5]        Set if overflow in DAC multiplexer
    1[6]        Set if DAC min/max/sum accmulator overflow
    1[7]        Set if DAC FIR overflow

W   2       Set ADC control parameters
W   2[13:0]     Set ADC input threshold limit
    2[15]       Set ADC lane phase (one tick fine delay)
    2[31:16]    Set bunch by bunch motion limit
R   2       Read to switch min/max/sum and read capture count
    2[28:0]     Number of turns in last capture
    2[29]       Set if turn accumulator overflowed
    2[30]       Set if sum register overflowed
    2[31]       Set if sum of squares register overflowed
W   3[31:7] Write FIR taps
R   3       Read min/max/sum

RW  4       Set bunch by bunch control parameters
    4[8:0]      Number of bunches in ring (/2), determines revolution frequency
    4[20:12]    Offset for bunch zero
    4[25:24]    Select back to be written
W   5       Configure selected bank
    5[1:0]      Selected FIR bank
    5[4]        Enable FIR output
    5[5]        Enable NCO0 output
    5[6]        Enable NCO1 output
    5[31:19]    Output gain

-   6           (unused)

RW  7       Bunch by bunch FIR control parameters
    7[1:0]      FIR bank to be written
    7[8:2]      Decimation count (N-1)
    7[11:9]     Scaling shift after decimation
W   8[31:7] Write FIR taps for selected bank

W   9       Configure DAC output settings
    9[9:0]      Output delay
    9[15:12]    NCO0 gain
    9[19:16]    NCO1 gain
    9[24:20]    FIR output gain
    9[25]       Enable FIR output
    9[26]       Enable NCO0 output
    9[27]       Enable NCO1 output
R   9       Read to switch min/max/sum and read capture count
    9[28:0]     Number of turns in last capture
    9[29]       Set if turn accumulator overflowed
    9[30]       Set if sum register overflowed
    9[31]       Set if sum of squares register overflowed
W   10[31:7] Write FIR taps
R   10      Read min/max/sum

RW  11[1:0] Select current bunch bank (will be under sequencer control)
RW  12      NCO0 frequency (will be under sequencer control)
RW  13      NCO1 frequency (will be under Tune PLL control)


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
