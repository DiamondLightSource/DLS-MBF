Diamond Light Source Multi-Bunch Feedback Processor (MBF)
=========================================================

This repository contains the firmware and software sources for running bunch by
bunch feedback on a synchrotron.  The firmware and software was developed at
Diamond Light Source and is designed to run on specific hardware documented
below.

Full documentation for using the system can be found at the `MBF Documentation`_
pages.  See the `Bringing up MBF`_ page for instructions on setting up MBF for
first operation.

..  _MBF Documentation: https://confluence.diamond.ac.uk/x/9obCB
..  _Bringing up MBF: https://confluence.diamond.ac.uk/x/_obCB

LICENSING
---------

The firmware in this repository (all files under the ``AMC525`` directory) has
been developed using commercial tools made available through the Europractice_
service.  As a consequence, this firmware is only available subject to an
agreement with Diamond Light Source that the firmware and its source may not be
redistributed and may not be commercially exploited.

This restriction does not apply to any of the other files in this repository.

..  _Europractice: http://www.europractice.stfc.ac.uk/welcome.html

MBF Components
--------------

This repository contains the following components.

Firmware
    The firmware is in the ``AMC525`` directory.  The targeted hardware is an
    AMC525 MicroTCA carrier card with an FMC500 ADC/DAC digitiser, and the
    firmware is built with Vivado 2016.4.

Kernel Driver
    The control system is designed to be run on a separate processor card on the
    same backplane as the AMC525 carrier card.  The register interface to the
    firmware is managed by a kernel driver in the ``driver`` directory.

EPICS Driver
    The control system is implemented as an EPICS IOC, all sources in the
    ``epics`` directory.  Note that currently only EPICS 3.14 is supported.  To
    build the EPICS driver and run the helper GUI scripts the following
    dependencies are required:

    =============== ======= ====================================================
    Component       Version Download from
    =============== ======= ====================================================
    EPICS           3.14    https://epics.anl.gov/base/index.php
    epics_device    1.4     https://github.com/Araneidae/epics_device
    epicsdbbuilder  1.2     https://github.com/Araneidae/epicsdbbuilder
    cothread        2.14    https://github.com/dls-controls/cothread
    =============== ======= ====================================================

Tune Fitter
    A separate EPICS IOC is provided for computing machine tune and sidebands
    from the result of tune sweeps.  This IOC is written in Python and uses the
    following tool:

    =============== ======= ====================================================
    Component       Version Download from
    =============== ======= ====================================================
    pythonIoc       2.11    https://github.com/Araneidae/pythonIoc
    =============== ======= ====================================================
