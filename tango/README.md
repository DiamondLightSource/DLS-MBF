# Tango Layer for the Diamond Light Source MBF
The Tango layer for MBF is an extra layer added on top of the EPICS layer. EPICS layer (together with EDM screens) can still be used in combination the the Tango Layer. Having a Tango layer have two main advantages:
1. The EPICS environment can be installed on MBF crate only.
2. MBF is then compatible with usual Tango tools (HDB for datalogging, ATKmoni for real-time graph plotting, etc.)

## Components

The Tango Layer is made of several servers and an application.

Servers are:
* **MBFStartIOC**
This server mimics the status of an IOC. When this server is started, it starts the corresponding IOC. When the IOC stops, the corresponding MBFStartIOC also stops. From a Tango point of view (Astor), the state of an IOC is reported by this device.
* **MacroServer**
This server will manage some Python macros that are used by *MBFControl*.
* **MBFControl**
It will configure the MBF system (using Python scripts) according to the value of some attributes it has.

The application is:
* **jmbf**
It can control a Transverse MBF (i.e. with two planes). For the moment there is not application for the Longitudinal MBF.

## Installation
### Prerequisites
You need to install two external Tango Servers on your control system:
* [MacroServer](https://pypi.org/project/sardana/)
* [Tango2Epics](https://sourceforge.net/p/tango-ds/code/HEAD/tree/DeviceClasses/Communication/Tango2Epics/)
### Server instantiation
Tango servers can only be installed once the EPICS layer on MBF crate is working.
1. Add some configuration parameters.
* Both epics and tune_fit IOC require some extra parameters in their configuration files (those parameters are not require for the EPICS layer). See examples:
  * epics: [SR-TMBF.config](https://github.com/DLS-Controls-Private-org/DLS-MBF/blob/ESRF/sites/ESRF/iocs/SR-TMBF.config "SR-TMBF.config")
  * epics lmbf: [SR-LMBF.config](https://github.com/DLS-Controls-Private-org/DLS-MBF/blob/ESRF/sites/ESRF/iocs/SR-TMBF.config "SR-TMBF.config")
  * tune_fit: [SR-TFIT.config](https://github.com/DLS-Controls-Private-org/DLS-MBF/blob/ESRF/sites/ESRF/iocs/SR-TFIT.config "SR-TFIT.config")
* Create a `$MBF_HOME/tango/tools/config.py`.
* Create a `$MBF_HOME/tango/tools/lmbf_config.py`.
* 
An example of this files can be found here: [config.py.l-c31-3](https://github.com/DLS-Controls-Private-org/DLS-MBF/blob/ESRF/sites/ESRF/tango/config.py.l-c31-3 "config.py.l-c31-3")
[lmbf_config.py](https://github.com/DLS-Controls-Private-org/DLS-MBF/blob/ESRF/sites/Elettra/tango/lmbf_config.py "lmbf_config.py")
3. Make the resources files to create Tango devices.
`cd $MBF_HOME/tango`
`make`
Generated resources files can be found in `$MBF_HOME/tango/server/resources`.
4.  Load resources files in your Tango database using Jive (File -> Load Property File).
5. Start Tango Devices on MBF crate using Astor (on the create Control window, double click your server in the list).

### Application installation
To be done

## Dependences
To be done.
