#
#	Copyright (c) 2013, Nenad Markus
#	All rights reserved.
#
#	This is an implementation of the algorithm described in the following paper:
#		N. Markus, M. Frljak, I. S. Pandzic, J. Ahlberg and R. Forchheimer,
#		A method for object detection based on pixel intensity comparisons,
#		http://arxiv.org/abs/1305.4537
#
#	Redistribution and use of this program as source code or in binary form,
#   with or without modifications, are permitted provided that the following
#   conditions are met:
#		1. Redistributions may not be sold, nor may they be used in a commercial
#          product or activity without prior permission from the copyright
#          holder (contact him at nenad.markus@fer.hr).
#		2. Redistributions may not be used for military purposes.
#		3. Any published work which utilizes this program shall include the
#          reference to the paper available at http://arxiv.org/abs/1305.4537
#		4. Redistributions must retain the above copyright notice and the
#          reference to the algorithm on which the implementation is based on,
#          this list of conditions and the following disclaimer.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
#   USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# The above copyright notice is copied from the original Pico source, which
# is distributed with this package. Note that this particular Cython file,
# pico.pyx, is separately licensed from the main Pico project (BSD 3-clause)
# which can be found in the main repository under LICENSE.md

# distutils: language = c++
# distutils: include_dirs = ./
# distutils: sources = cypico/picornt.c cypico/pico_wrapper.cpp
import numpy as np
cimport numpy as np
from cython cimport view
from .pico cimport pico_cluster_objects, pico_detect_objects, MODELS_LENS, MDL_ONE, MDL_TWO
from collections import namedtuple
from copy import deepcopy
import re
import binascii
import ctypes
np.import_array()

###TEST CASCADES]
test_memory = np.ascontiguousarray(np.zeros(1))

### FOR CUSTOM NUMBER OF PRODUCTION CASCADES, SET THE FOLLOWING PARAMS
# Remember to also change pico_wrapper.h and pico.pxd as appropriate
NUM_CASCADES = 2
#Recreate Lengths
mdl_lens = <long[:NUM_CASCADES]> MODELS_LENS

cdef view.array CASCADE_ONE = view.array(
    shape=(mdl_lens[0],), itemsize=sizeof(unsigned char), format='B',
    mode='c', allocate_buffer=False)
CASCADE_ONE.data = <char *> MDL_ONE

cdef view.array CASCADE_TWO = view.array(
    shape=(mdl_lens[1],), itemsize=sizeof(unsigned char), format='B',
    mode='c', allocate_buffer=False)
CASCADE_TWO.data = <char *> MDL_TWO

mdl_map = {1: CASCADE_ONE, 2: CASCADE_TWO, 'faces': CASCADE_ONE} #USED to identifier model
### ADJUST AS REQUIRED

# Create a namedtuple to store a single detection
PicoDetection = namedtuple('PicoDetection', ['confidence', 'center', 'diameter', 
                                             'orientation'])

cpdef load_cascade(abs_path):
    global test_memory
    load = None
    with open(abs_path, 'rb') as f:
        load = f.read()
    load = re.sub(r'[^a-zA-Z0-9]','', load)
    load = load.replace('0x', '')
    load = binascii.unhexlify(load)
    test_memory = np.ascontiguousarray(np.array([ord(i) for i in load],  dtype=np.uint8))
    print('Successfully loaded cascade: ' + abs_path)

cpdef detect(unsigned char[:, :] image, config, cascade_identifier):
    r"""
    Detect faces in the given image. It will detect multiple faces and has
    the ability to detect faces that have been *in-plane* rotated. This implies
    upside down faces, but not faces turned profile.

    Parameters
    ----------
    image : `unsigned char[:, :]`
        The image to detect faces within. Should be a `uint8` image with values
        in the range 0 to 255.
    max_detections : `int`, optional
        The maximum number of detections to return.
    orientations : list of `float`s or `float`, optional
        The orientations of the cascades to use. ``0.0`` will perform an
        axis aligned detection. Values greater than ``0.0`` will perform
        detections of the cascade rotated counterclockwise around a unit circle.
        If a list is passed, each item should be an orientation in
        radians around the unit circle, with ``0.0`` being axis aligned.
    scale_factor : `float`, optional
        The ratio to increase the cascade window at every iteration. Must
        be greater than 1.0
    stride_factor : `float`, optional
        The ratio to decrease the window step by at every iteration. Must be
        less than 1.0, optional
    min_size : `float`, optional
        The minimum size in pixels (diameter of the detection circle) that a
        face can be. This is the starting cascade window size.
    confidence_cutoff : `float`, optional
        The confidence value to trim the detections with. Any detections with
        confidence less than the cutoff will be discarded.

    Returns
    -------
    detections : list of ``PicoDetection``
        The list of detections. Each ``PicoDetection`` represents a single
        detection. A ``PicoDetection`` returns the confidence of the detection,
        the centre coordinates of the circle ((y, x) as is common for images)
        and the diameter of the circle.

    Raises
    ------
    ValueError:
        If ``scale_factor`` is less than or equal to 1.0
        If ``stride_factor`` is greater than or equal to 1.0
    """
    cdef view.array MANUAL
    cdef np.ndarray[np.uint8_t] load_view
    if cascade_identifier == 'manual' and len(test_memory) < 2:
        raise Exception('Error with custom cascade!')
    max_detections=orientations=scale_factor=stride_factor=min_size=confidence_cutoff=None
    try:
        max_detections = config['max_detections']        
    except KeyError:
        max_detections = 100
    try:
        orientations = config['orientations']        
    except KeyError:
        orientations = 0.0
    try:
        scale_factor = config['scale']        
    except KeyError:
        scale_factor = 1.2
    try:
        stride_factor = config['stride']        
    except KeyError:
        stride_factor = 0.1
    try:
        min_size = config['min_size']        
    except KeyError:
        min_size = 100
    try:
        confidence_cutoff = config['confidence']        
    except KeyError:
        confidence_cutoff = 3.0
    if cascade_identifier == 'manual':
        load_view = test_memory
        MANUAL = view.array(shape=(len(test_memory),), itemsize=sizeof(unsigned char), format='B', mode='c', allocate_buffer=False)
        MANUAL.data = <char *> &load_view[0]
        return detect_objects(image, MANUAL,
                          max_detections=max_detections,
                          orientations=orientations, scale_factor=scale_factor,
                          stride_factor=stride_factor, min_size=min_size,
                          confidence_cutoff=confidence_cutoff)
    else:
        return detect_objects(image, mdl_map[cascade_identifier],
                          max_detections=max_detections,
                          orientations=orientations, scale_factor=scale_factor,
                          stride_factor=stride_factor, min_size=min_size,
                          confidence_cutoff=confidence_cutoff)




cpdef detect_objects(unsigned char[:, :] image, unsigned char[::1] cascades,
                     int max_detections, orientations,
                     float scale_factor, float stride_factor,
                     float min_size, float confidence_cutoff):
    r"""
    Detect objects in the given image. It will detect multiple objects and has
    the ability to detect objects that have been *in-plane* rotated. This
    implies upside down objects, but not faces turned out of plane. The cascades
    used to train the detector must be passed as an unsigned char array.

    Parameters
    ----------
    image : `unsigned char[:, :]`
        The image to detect objects within. Should be a `uint8` image with
        values in the range 0 to 255.
    cascades :  `unsigned char[:]`
        The trained cascades to use for object detection. This should be trained
        using the cypico training function.
    max_detections : `int`, optional
        The maximum number of detections to return.
    orientations : list of `float`s or `float`, optional
        The orientations of the cascades to use. ``0.0`` will perform an
        axis aligned detection. Values greater than ``0.0`` will perform
        detections of the cascade rotated counterclockwise around a unit circle.
        If a list is passed, each item should be an orientation in
        radians around the unit circle, with ``0.0`` being axis aligned.
    scale_factor : `float`, optional
        The ratio to increase the cascade window at every iteration. Must
        be greater than 1.0
    stride_factor : `float`, optional
        The ratio to decrease the window step by at every iteration. Must be
        less than 1.0, optional
    min_size : `float`, optional
        The minimum size in pixels (diameter of the detection circle) that a
        face can be. This is the starting cascade window size.
    confidence_cutoff : `float`, optional
        The confidence value to trim the detections with. Any detections with
        confidence less than the cutoff will be discarded.

    Returns
    -------
    detections : list of ``PicoDetection``
        The list of detections. Each ``PicoDetection`` represents a single
        detection. A ``PicoDetection`` returns the confidence of the detection,
        the centre coordinates of the circle ((y, x) as is common for images)
        and the diameter of the circle.

    Raises
    ------
    ValueError:
        If ``scale_factor`` is less than or equal to 1.0
        If ``stride_factor`` is greater than or equal to 1.0
    """
    if scale_factor <= 1.0:
        raise ValueError('Scale factor must be greater than 1.0')
    if stride_factor >= 1.0:
        raise ValueError('Scale factor must be less than 1.0')

    cdef float[:] orientations_arr
    if isinstance(orientations, (int, long, float, np.float32, np.float64)):
        orientations = [orientations]
    orientations_arr = np.asarray(orientations, dtype=np.float32)

    cdef:
        int i = 0
        int height = image.shape[0]
        int width = image.shape[1]
        int n_detections = 0
        int n_orientations = orientations_arr.shape[0]
        float[:] output           = np.zeros(4*max_detections, dtype=np.float32)
        float[:] out_orientations = np.zeros(max_detections, dtype=np.float32)

    n_detections = pico_detect_objects(&image[0, 0], 
                                       height, 
                                       width,
                                       width, 
                                       &cascades[0],
                                       max_detections, 
                                       n_orientations,
                                       &orientations_arr[0],
                                       scale_factor, 
                                       stride_factor,
                                       min_size, 
                                       confidence_cutoff,
                                       &output[0],
                                       &out_orientations[0])

    results = []
    for i in range(n_detections):
        if output[4*i+3] > confidence_cutoff:
            results.append(
                PicoDetection(
                    output[4*i+3],
                    np.array([output[4*i], output[4*i+1]]),
                    output[4*i+2],
                    out_orientations[i]
                )
            )
    return results

cpdef remove_overlap(detections):
    n_detections = len(detections)
    cdef float[:] arr = np.zeros(4*n_detections, dtype=np.float32)
    if n_detections > 0:
        results_out = []
        orientation_sum = 0
        for i in range(n_detections):
            cur = detections[i]
            arr[4*i] = cur[1][0]
            arr[4*i+1] = cur[1][1]
            arr[4*i+2] = cur[2]
            arr[4*i+3] = cur[0]
            orientation_sum+= detections[i][3]
        n_detections = pico_cluster_objects(&arr[0], n_detections)
        for i in range(n_detections):
            results_out.append(
                PicoDetection(
                    arr[4*i+3],
                    np.array([arr[4*i], arr[4*i+1]]),
                    arr[4*i+2],
                    orientation_sum/len(detections)
                )
            )
        return results_out
    else:
        return []
