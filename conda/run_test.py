import sys
import os
import cypico
import numpy as np
from PIL import Image


if __name__ == "__main__":
    try:
        recipe_filepath = os.environ.get('RECIPE_DIR', os.path.dirname(os.path.abspath(__file__)))
        lena_path = os.path.join(recipe_filepath, 'lena.png')
        
        lena = np.mean(np.array(Image.open(lena_path)), axis=-1).astype(np.uint8)
        results = cypico.detect_frontal_faces(lena)
        print('Found {} faces'.format(len(results)))
        assert(len(results) > 0)
    except Exception as e:
        print(e)
        sys.exit(1)

