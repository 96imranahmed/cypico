cypico
======
A Cython wrapping of the pico face detection project. 

Please see the `LICENSE.md` file for information on the licensing.

Installation
------------
Install using Python:

``python(3) setup.py build_ext --inplace``

Then,

``(sudo) python(3) setup.py install``

If using python3, stay consistent - otherwise Cython build errors will occur

### Loading new models
First use bin2hex (included) to convert model generated from standard pico
implementation:
`https://github.com/nenadmarkus/pico - current commit: 45564fc 16 Nov 2016`

Alternatively, you can also use:
`http://tomeko.net/online_tools/file_to_hex.php?lang=en`

Place new cascade (save with extension .hex) in the `cypico` directory along 
with the other cascade and change `pico_wrapper.h` to point to new cascade.

Reinstall cypico as above!

TODO (From old repo)
---------------------
### Loading Pico Models
By default, Pico models are saved down as raw data, loaded into a ``char*``
array, then cast into the members of the C-struct they actually represent.

To make this cleaner, the C-struct would need to be created in cypico so that
Pico models can be properly loaded and saved. Then, the Pico struct could be
wrapped inside a Python object so that they could be loaded off of disk
and passed around properly. This would also solve the pretty strange paradigm
I've had to take in order to get the prebuilt frontal face model passed into
the generic Pico detector.

Ideally, Pico models would be wrapped by some Python object (with a proper
Cython struct wrapping a C-struct being held) and then the frontal face detector
would be one of these objects and would be loaded off of disk at runtime as
opposed to compiled into the detector.

### Training Pico Models
Training code is not currently wrapped. The issue of loading Pico models must be
solved before training could be properly attempted.

