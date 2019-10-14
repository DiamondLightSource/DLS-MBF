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
    epics_device    1.5     https://github.com/Araneidae/epics_device
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
    pythonIoc       2.15    https://github.com/Araneidae/pythonIoc
    =============== ======= ====================================================


Release Notes
-------------

1.0.0 May 2018
..............

This was the first working release deployed at DLS.

1.0.1 June 2018
...............

Minor bug fixes and refinements.

1.1.0 August 2018
.................

Bug fixes, some structural renaming: at this point LMBF was renamed to MBF
throughout the project.

1.1.2 January 2019
..................

Minor changes:

* Some improvements to the tune fitting algorithm to improve robustness.
* Add selector to tune fitter to just take maximum value as proxy for peak.
* Bunch-by-bunch control waveform editing has been improved.

1.2.0 March 2019
................

The firmware for this release is strictly incompatible with the 1.0 and 1.1
releases, and this is now checked during startup.  The following features have
been added:

* Tune PLL tracking is now available.  This is the major change in this release.
* NCO frequencies are now 48 bits wide (rather than 32 bits).  This means that
  frequency resolution will no longer be an issue anywhere.
* Bunch by bunch gain control now has option for up to +30dB of extra gain.
* New bunch rejection filter added for detector data.
* Two changes to sequencer: now have optional holdoff at start of dwell, and can
  optionally apply tune PLL offset as extra offset to sweep frequency.

1.2.1 June 2019
...............

Minor tweaks, no change to firmware.  ``mbf_memory`` Python library merged.
``mbf_read_tune_pll.m`` script rewritten and API changed.  Minor PV changes:

* Remove ``BUN:n:ALL:SET_S`` PV: too easy to press by mistake and really
  somewhat redundant.
* Change semantics of ``ADC:THRESHOLD_S`` (LMBF only).

1.3.0 September 2019
....................

Mostly small changes to tune fitting, however the graphs have changed to show
magnitude and phase rather than power, and data weighting during fit is
configurable.

One incompatible change is to correct the calculation of detector phase, which
now correctly advances in the negative direction with increasing frequency.
This affects the detector IQ and phase waveforms as well as the tune fitting.

This software is compatible with version 1.2.0 of the firmware which has not
changed.
