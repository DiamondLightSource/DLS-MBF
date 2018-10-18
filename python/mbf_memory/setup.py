#-*- coding: utf8 -*-
from setuptools import setup

# these lines allow the version to be specified in Makefile.private
import os

setup(
    name = 'mbf_memory',
    version = '1.0.1',
    description = 'Access MBF memory (DMA)',
    author = 'Benoît Roche',
    author_email = 'benoit.roche@esrf.fr',
packages = ['mbf_memory'])
