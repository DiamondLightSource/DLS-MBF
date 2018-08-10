============================
Kernel Driver for AMC525 MBF
============================

.. default-role:: literal

Development Notes
-----------------

The driver can be installed in three different ways:

1.  Build in place and insert with `make insmod`.  This is suitable for
    development during development.

2.  Install with `dkms`.  This will insert the module into the kernel tree, and
    ensure that it is loaded during boot (if the firmware is already loaded) and
    keep the driver in step with the kernel.

3.  Install with `rpm`.  This is used to manage a dkms install.

Separately from `dkms` it is desirable to install the appropriate `udev` file so
that the permissions are set up correctly.


udev Configuration
~~~~~~~~~~~~~~~~~~

The file `driver/11-amc525_mbf.rules` needs to be installed under
`/etc/udev/rules.d`, and may need to be modified to suit the local environment.
This file performs the following actions during the loading of the driver:

1.  The access permissions and ownership are set so that group `dcs` (a DLS
    specific role) has full access to the device.

2.  A subdirectory `/dev/amc525_mbf` is created with a geographical device name
    containing aliases for each device node.  This is designed to be used when
    more than one AMC525 MBF card is present in a system.

Note that the syntax for udev rules seems to change from system to system, our
set up is for Red Hat Enterprise Linux 7 (RHEL7).  For debugging, the following
commands are helpful:

`$ udevadm monitor -kup`
    Logs udev events to the console.  Unfortuately doesn't seem to log failures!

`$ udevadm test /path/to/device`
    Triggers and logs test activation of udev rules for specified device name,
    for example `/class/amc525_mbf/amc525_mbf.0.reg`.

`# udevadm control --reload`
    Sometimes it is necessary to force the udev database to be reloaded.

`# udevadm trigger --attr-match=subsystem=amc525_mbf`
    Retriggers udev rules.



Installation using dkms
~~~~~~~~~~~~~~~~~~~~~~~

The `make install-dkms` command must be run as root (and may leave root owned
files in the build directory).  This installs the udev rule and the sources and
runs the dkms `add`, `build`, `install` commands.


Using `rpmbuild`
~~~~~~~~~~~~~~~~

Annoyingly difficult to find sensible documentation for `rpmbuild`.  Here are a
variety of urls:

| http://reality.sgiweb.org/davea/rpmbuild.html
| http://www.ibm.com/developerworks/library/l-rpm1/
| http://www.rpm.org/max-rpm/index.html
| http://www.rpm.org/max-rpm-snapshot

.. vim: filetype=rst:
