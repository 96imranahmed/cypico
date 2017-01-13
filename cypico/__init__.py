from .pico import detect_frontal_faces, detect_objects, remove_overlap

from ._version import get_versions
__version__ = get_versions()['version']
del get_versions
