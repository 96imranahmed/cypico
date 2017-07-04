cypico (Updated)
======
A Cython wrapping of the pico face detection project. 

Please see the `LICENSE.md` file for information on the licensing.

## Specific Changes in this Fork
Solves many of the TODOs mentioned in the original cypico package

1. Supports loading a cascade into memory at runtime (refer to `load_cascade` method)
2. Processes and returns correct orientations
3. Splits out the `remove_overlap()` method for additional clarity
4. Supports the use of multiple cascades (see documentation in code) within the same installation

Installation
------------
Install using Python:

``python(3) setup.py build_ext --inplace``

Then,

``(sudo) python(3) setup.py install``

If using python3, run both commands in python3 to avoid Cython build errors

### Installing New Models
Loading cascades into memory at runtime function now  supports loading the models directly from the output models from Cypico! (Woo)!

First use bin2hex (included) to convert model generated from standard pico
implementation:
`https://github.com/nenadmarkus/pico - current commit: 45564fc 16 Nov 2016`

Alternatively, you can also use:
`http://tomeko.net/online_tools/file_to_hex.php?lang=en`

Place new cascade(s) (save with extension .hex) in the `cypico` directory and change `pico_wrapper.h` to point to new cascade(s) as required.

Reinstall cypico as above!
