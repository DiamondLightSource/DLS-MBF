#-*- coding: utf8 -*-
from setuptools import setup

# these lines allow the version to be specified in Makefile.private
import os
version = os.environ.get("MODULEVER", "development")

setup(
    name = 'mbf_memory',
    version = version,
    description = 'Access MBF memory (DMA)',
    author = 'Benoît Roche',
    author_email = 'benoit.roche@esrf.fr',
packages = ['mbf_memory'])
