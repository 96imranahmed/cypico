from setuptools import setup, find_packages
from Cython.Build import cythonize
import numpy as np


cython_modules = ['cypico/pico.pyx']

requirements = ['numpy>=1.10,<=2.0', 'Cython>=0.23,<=0.24']

setup_options = dict(name='cypico',
      description='A Cython wrapper around the Pico face detection library. Extended for C-API by Imran Ahmed (96imranahmed@gmail.com)',
      author='Patrick Snape',
      author_email='p.snape@imperial.ac.uk',
      url='https://github.com/menpo/cypico',
      include_dirs=[np.get_include()],
      ext_modules=cythonize(cython_modules, quiet=True),
      package_data={'cypico': ['picornt.c',
                               'picornt.h',
                               'pico.pyx',
                               'pico.pxd',
                               'pico_wrapper.h',
                               'pico_wrapper.cpp']},
      install_requires=requirements,
      packages=find_packages()
)

#Hack for OSX Python 3.5 (see 'numpy/arrayobject.h' file not found, cython, osx)
for em in setup_options["ext_modules"]:
    em.include_dirs = [np.get_include()]

setup(**setup_options)
