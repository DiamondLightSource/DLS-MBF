#!/usr/bin/env python2
#-*- coding: utf-8 -*-

import numpy as np
import argparse
import socket

class MBF_mem():
    BUFFER_SIZE = 1024

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
            hostname_l = dev_tango.HOSTNAME
            port = dev_tango.SOCKET
        elif layer == 'epics':
            self.bunch_nb = catools.caget(device_name + ":INFO:BUNCHES")
            hostname_l = catools.caget(device_name + ":INFO:HOSTNAME")
            port = catools.caget(device_name + ":INFO:SOCKET")

        self.device_name = device_name
        hostname = "".join(map(chr, hostname_l))
        hostname = hostname.rstrip("\0")
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.connect((hostname, port))

    def __del__(self):
        self.s.close()

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

    def __read_buffer(self, data_size):
        data = ""
        while data_size > 0:
            d = self.s.recv(data_size)
            if not d:
                # Early end of input
                break
            data += d
            data_size -= len(d)
        return data

    def __get_tpe(self, type_str):
        dt = np.dtype(np.__dict__[type_str])
        dt = dt.newbyteorder('<')
        return dt

    def read_mem(self, turns, offset=0, channel=None, bunch=None,
            decimate=None, tune=None, lock=None, verbose=False):
        """
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
        expected_msg_len = turns
        msg_fmt = 'int16'

        if channel is not None:
            if channel not in [0, 1]:
                raise ValueError("channel should be: None, 0 or 1")
            cmd_str += "C{}".format(channel)
            channel_nb = 1
        else:
            channel_nb = 2
        expected_msg_len *= channel_nb

        if bunch is not None:
            if (int(bunch) < 0) or (int(bunch) >= self.bunch_nb):
                raise ValueError("bunch should be between 0 and {}".format(
                    self.bunch_nb))
            cmd_str += "B{}".format(int(bunch))
        else:
            expected_msg_len *= self.bunch_nb

        if decimate is not None:
            if (int(decimate) < 1) or \
                    (int(decimate) > self.get_max_decimate()):
                raise ValueError("decimate should be between 1 and {}".\
                                format(self.get_max_decimate()))
            cmd_str += "D{}".format(int(decimate))
            msg_fmt = 'float32'

        if tune is not None:
            cmd_str += "T{}".format(float(tune))
            msg_fmt = 'complex64'

        out_type = np.__dict__[msg_fmt]
        expected_msg_len *= np.dtype(out_type).itemsize

        if lock is not None:
            cmd_str += "L"
            if lock > 0:
                cmd_str += "W{:.0f}".format(lock*1000)

        if verbose:
            print "cmd_str:", cmd_str, " | ", expected_msg_len

        self.s.send(cmd_str + '\n')
        data = self.__read_buffer(self.BUFFER_SIZE)

        if data[0] != chr(0):
            raise NameError(data)

        recv_bytes = len(data)
        data += self.__read_buffer(8-recv_bytes)

        # Get header data
        header_samples = np.frombuffer(data[1:5],
            dtype=self.__get_tpe('uint32'))[0]
        header_ch_per_samples = np.frombuffer(data[5:7],
            dtype=self.__get_tpe('uint16'))[0]
        header_sample_format = np.frombuffer(data[7:9],
            dtype=self.__get_tpe('uint16'))[0]

        bytes_per_sample = {0: 2, 1: 4, 2: 8}
        expected_msg_len_bis = header_samples*header_ch_per_samples
        expected_msg_len_bis *= bytes_per_sample[header_sample_format]

        if verbose:
            print "samples:", header_samples
            print "ch_per_sample", header_ch_per_samples
            print "format", header_sample_format
            print "expected_msg_len", expected_msg_len_bis

        data = data[9:]
        recv_bytes = len(data)
        data += self.__read_buffer(expected_msg_len-recv_bytes)

        d = np.frombuffer(data, dtype=self.__get_tpe(msg_fmt))
        d.shape = (-1, channel_nb)

        return d.T

    def read_det(self, channel=0, lock=None, verbose=False):
        """
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
d : ndarray of complex128 with shape (N_samples, nb_detec)
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
        if channel not in [0, 1]:
            raise ValueError("channel should be: 0 or 1")
        cmd_str = "D{}FST".format(int(channel))
        if lock is not None:
            cmd_str += "L"
            if lock > 0:
                cmd_str += "W{:.0f}".format(lock*1000)

        if verbose:
            print "cmd_str:", cmd_str

        self.s.send(cmd_str + '\n')

        # First read the header
        data = self.__read_buffer(self.BUFFER_SIZE)

        if data[0] != chr(0):
            raise NameError(data)

        recv_bytes = len(data)
        expected_msg_len = 13
        data += self.__read_buffer(expected_msg_len-recv_bytes)

        # Get header data
        header_nb_detec = np.frombuffer(data[1],
            dtype=self.__get_tpe('uint8'))[0]
        header_mask_detec = np.frombuffer(data[2],
            dtype=self.__get_tpe('uint8'))[0]
        header_comp_delay = np.frombuffer(data[3:5],
            dtype=self.__get_tpe('uint16'))[0]
        header_N = np.frombuffer(data[5:9],
            dtype=self.__get_tpe('int32'))[0]
        header_bunches = np.frombuffer(data[9:13],
            dtype=self.__get_tpe('int32'))[0]

        expected_msg_len = header_nb_detec*header_N*8

        if verbose:
            print "N: ", header_N
            print "Nb of detectors: ", header_nb_detec
            print "bunches:", header_bunches
            print "Compensation delay:", header_comp_delay
            print "expected_msg_len: ", expected_msg_len

        data = data[13:]
        recv_bytes = len(data)
        data += self.__read_buffer(expected_msg_len-recv_bytes)

        d = np.frombuffer(data, dtype=self.__get_tpe('int32'))
        d.shape = (header_N, header_nb_detec, 2)
        d_cmpl = d[:, :, 0] + 1j*d[:, :, 1]
        d_cmpl /= 2**31

        expected_msg_len = 4*header_N
        data = self.__read_buffer(expected_msg_len)
        s = np.frombuffer(data, dtype=self.__get_tpe('uint32'))
        s = header_bunches * s.astype(np.float64) / 2**32
        data = self.__read_buffer(expected_msg_len)
        t = np.frombuffer(data, dtype=self.__get_tpe('uint32'))

        # Compute corrected data
        group_delay = 2.0 * np.pi * header_comp_delay / header_bunches
        correction = np.exp(-1j * group_delay * s)
        d_cmpl *= correction[:,np.newaxis]

        return d_cmpl, s, t


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
