#!/usr/bin/env python2
#-*- coding: utf-8 -*-

import numpy as np
import argparse
import socket
import struct


class MBF_mem():
    # Array for decoding memory readback sample types
    sample_types = {0: np.int16, 1: np.float32, 2: np.complex64}


    def __init__(self, device_name, layer='epics'):
        """
    Connect to MBF system.

Parameters :
    - device: The Tango or EPICS name of the MBF system.
    - layer : Which layer will be use to get information on the system
              (hostname, port, bunches). Can be either 'epics' or 'tango'.
Return      :
Throws      :

Example     :
        """
        layer = layer.lower()
        self.layer = layer
        if layer == 'tango':
            import PyTango
        elif layer == 'epics':
            from cothread import catools

        if layer == 'tango':
            dev_tango = PyTango.DeviceProxy(device_name)
            self.dev_tango = dev_tango
            self.bunch_nb = dev_tango.BUNCHES
            hostname = dev_tango.HOSTNAME
            port = dev_tango.SOCKET
        elif layer == 'epics':
            self.bunch_nb = catools.caget(device_name + ":INFO:BUNCHES")
            hostname = catools.caget(device_name + ":INFO:HOSTNAME",
                datatype = catools.DBR_CHAR_STR)
            port = catools.caget(device_name + ":INFO:SOCKET")

        self.device_name = device_name
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((hostname, port))
        self.s = s.makefile()


    def get_turn_min_max(self):
        if self.layer == 'tango':
            runout_ = self.dev_tango.MEM_RUNOUT_S
        elif self.layer == 'epics':
            from cothread import catools
            runout_ = catools.caget(self.device_name + ":MEM:RUNOUT_S")
        runout = [0.125, 0.25, 0.5, 0.75, 255./256][runout_]
        min_turn = np.ceil(((runout-1)*2.**29)/self.bunch_nb)
        max_turn = np.floor((runout*2.**29)/self.bunch_nb)
        return min_turn, max_turn

    def get_turns_max(self, decimate):
        return ((2**29)//self.bunch_nb)//decimate

    def get_max_decimate(self):
        READ_BUFFER_BYTES = 2**20-64
        sizeof_uint32 = 4
        buffer_size = READ_BUFFER_BYTES  / sizeof_uint32 - self.bunch_nb
        return int(np.ceil((1.*buffer_size) / self.bunch_nb) - 1)

    def read_mem_avg(self, turns, offset=0, channel=None, decimate=None,
            tune=None, lock=None, verbose=False):
        d = self.read_mem(turns, offset=offset, channel=channel,
            decimate=decimate, tune=tune, lock=lock, verbose=verbose)
        n = np.size(d)
        out_buffer_size = self.bunch_nb
        if channel is None:
            out_buffer_size *= 2
        N = n//out_buffer_size
        d.shape = (N, out_buffer_size)
        return d.mean(0)


    # Sends the given command and checks the response for success.  If an error
    # code is returned an exception is raised.
    def __send_command(self, command, verbose):
        if verbose:
            print "cmd_str:", command

        self.s.write(command + '\n')
        self.s.flush()
        status = self.s.read(1)
        if status[0] != '\0':
            error = self.s.readline()
            raise NameError(status + error[:-1])   # Need to trim \n from line


    def read_mem(self, turns, offset=0, channel=None, bunch=None,
            decimate=None, tune=None, lock=None, verbose=False):
        """\
Reads out the currently captured detectors for the given axis.  If no axis is
specified, the default is 0.

Parameters
----------
turns    : int
    Number of samples to read (not the number of turns if decimate is used).

offset   : int
    Offset in turns from the trigger point from which to start returning data.
    This can be positive or negative.

channel  : int or None
    Channel number (0 or 1).
    If None, the returned array has two columns (first dimension is 2),
    one for each captured channel.

bunch    : int or None
    Readout of a specific bunch instead of a complete turns.

decimate : int or None
    Bunch-by-bunch binned averaging of data. Cannot be combined with 'bunch'.

tune     : float or None
    Data will be frequency shifted by the given tune (in units of rotations
    per machine revolution). Cannot be combined with 'bunch'.

lock     : float or None
    Lock the readout channel to ensure that memory capture is not armed and is
    not retriggered during readout.
    The value is a timeout in seconds, if the memory cannot be locked within
    this time the readout will fail.
    If None, doesn't try to lock the channel.

verbose  : bool
    Activates verbose mode

Returns
-------
d : 2d array of int16, float32 or complex64 with shape (channel_nb, samples)
    Type and shape depends on input arguments.

Raises
------
NameError
    if MBF returns an error.
"""
        cmd_str = "M{}FO{}".format(int(turns), int(offset))

        if channel is not None:
            cmd_str += "C{}".format(channel)

        if bunch is not None:
            cmd_str += "B{}".format(int(bunch))

        if decimate is not None:
            cmd_str += "D{}".format(int(decimate))

        if tune is not None:
            cmd_str += "T{}".format(float(tune))

        if lock is not None:
            cmd_str += "L"
            if lock > 0:
                cmd_str += "W{:.0f}".format(lock*1000)


        self.__send_command(cmd_str, verbose)


        # First read and decode the header
        header = struct.unpack('<IHH', self.s.read(8))
        samples = header[0]
        channels = header[1]
        format = header[2]

        data_type = self.sample_types[format]
        length = samples * channels * data_type().itemsize

        if verbose:
            print "samples:", samples
            print "ch_per_sample", channels
            print "format", header_sample_format
            print "expected_msg_len", length

        data = self.s.read(length)
        return np.frombuffer(data, dtype = data_type).reshape(-1, channels).T


    def read_det(self, channel=0, lock=None, verbose=False):
        """\
Reads out the currently captured detectors for the given axis.  If no axis is
specified, the default is 0.

Parameters
----------
channel : int
    Channel number (0 or 1).

lock : float or None
    Locks the detector readout channel and throws an error after
    lock seconds if the channel cannot be locked.
    If None, doesn't try to lock the channel.

verbose : bool
    Activates verbose mode

Returns
-------
d : ndarray of complex128 with shape (nb_detec, N_samples)
    detector(s) data

s : array
    Frequency scale in units of cycles per turn.

t : array
    Timebase scale in units of turns.

Raises
------
NameError
    if MBF returns an error.
"""

        cmd_str = "D{}FSLT".format(int(channel))
        if lock is not None:
            cmd_str += "L"
            if lock > 0:
                cmd_str += "W%d" % (lock * 1000)

        self.__send_command(cmd_str, verbose)


        # First read the header
        header = struct.unpack('<BBHII', self.s.read(12))

        # Get header data
        det_count = header[0]
        det_mask = header[1]
        compensation_delay = header[2]
        sample_count = header[3]
        bunch_count = header[4]

        if verbose:
            print "N: ", sample_count
            print "Nb of detectors: ", det_count
            print "bunches:", bunch_count
            print "Compensation delay:", compensation_delay

        # First read the detector data
        data = self.s.read(sample_count * det_count * 8)
        d = np.frombuffer(data, dtype=np.int32)
        d.shape = (sample_count, det_count, 2)
        d_cmpl = d[:, :, 0] + 1j*d[:, :, 1]
        d_cmpl *= 2**-31

        # Next the frequency scale
        data = self.s.read(sample_count * 8)
        s = np.frombuffer(data, dtype=np.uint64)
        s = bunch_count * s.astype(np.float64) * 2**-48

        # Finally the timebase
        data = self.s.read(sample_count * 4)
        t = np.frombuffer(data, dtype=np.uint32)

        # Compute corrected data
        group_delay = 2.0 * np.pi * compensation_delay / bunch_count
        correction = np.exp(-1j * group_delay * s)
        d_cmpl *= correction[:, np.newaxis]

        return (d_cmpl.T, s, t)


def read_mem(device_name, turns, offset=0, channel=None, layer='epics',
        **kargs):
    return MBF_mem(device_name, layer).read_mem(turns, offset, channel, **kargs)

def read_det(device_name, channel=0, layer='epics', **kargs):
    return MBF_mem(device_name, layer).read_det(channel, **kargs)


__all__ = ['MBF_mem', 'read_mem', 'read_det']


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Read memory buffer.")
    parser.add_argument("-c", default=None, type=int,
        help="Channel number", dest="channel")
    parser.add_argument("-d", type=str,
        help="TMBF device name (EPICS or Tango)", dest="device_name")
    parser.add_argument("-l", default="epics", type=str,
        help="Layer: 'tango' or 'epics'", dest="layer")
    parser.add_argument("-t", default=None, type=float,
        help="Frequency for homodyne detection (in SR turns units)",
        dest="tune")
    args = parser.parse_args()

    device_name = args.device_name
    layer = args.layer
    tune = args.tune
    channel = args.channel

    mbf = MBF_mem(device_name, layer=layer)

    bunch = None
    decimate = mbf.get_max_decimate()
    turns = mbf.get_turns_max(decimate)
    min_turn, _ = mbf.get_turn_min_max()
    offset = min_turn

    data = mbf.read_mem(turns, offset, channel, bunch, decimate, tune)
    print data
