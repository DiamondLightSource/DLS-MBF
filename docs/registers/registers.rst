MBF Register Reference
======================

.. footer::
    Page ###Page###. ###Section###

The control register address space consists of 16384 32-bit words organised into
four active banks with the following word addressing:

=============== ======= ============================================
Word Address    Name    Controlled bank
=============== ======= ============================================
0x0000..0x1FFF  SYS     System registers: top level hardware control
0x2000..0x27FF  CTRL    DSP master control
0x2800..0x2FFF          (unused)
0x3000..0x37FF  DSP0    DSP 0 control
0x3800..0x3FFF  DSP1    DSP 1 control
=============== ======= ============================================

This address space is available by memory mapping ``/dev/amc525_mbf.0.reg``.
To obtain the byte address for each register multiply the corresponding word
address by 4.

The active registers in each bank are identified and named below.  Registers not
documented here will read as 0 with no side effect and will be ignored when
written.

..  register_docs_file::
    :file:      AMC525/vhd/register_defs.in


Constant Definitions
--------------------

The following constants are defined as part of the firmware build.

..  constant_docs::


System Registers
----------------

..  register_docs::
    :section:   SYS


Control Registers
-----------------

..  register_docs::
    :section:   CTRL


DSP Registers
-------------

..  register_docs::
    :section:   DSP

..  _MMS:

MMS Registers
~~~~~~~~~~~~~

..  register_docs::
    :group:     MMS

..  _TRIGGERS_IN:

Trigger Sources
~~~~~~~~~~~~~~~

..  register_docs::
    :register:  TRIGGERS_IN

Interrupt definitions
~~~~~~~~~~~~~~~~~~~~~

..  register_docs::
    :register:  INTERRUPTS
