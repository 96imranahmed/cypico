#pragma once
#include <math.h>
#include <string>

extern "C" {
    #include "picornt.h"
}

#ifndef MIN
    #define MIN(a, b) ((a)<(b)?(a):(b))
#endif

#ifndef MAX
    #define MAX(a, b) ((a)>(b)?(a):(b))
#endif

static const unsigned char MDL_ONE[] =
{
    #include "face_original.hex"
};

// static const unsigned char MDL_TWO[] =
// {
//     #include "INSERT_NAME_HERE.hex"
// };

static const long MODELS_LENS[] = {(long) (sizeof(MDL_ONE) / sizeof(unsigned char)), (long) (sizeof(MDL_TWO) / sizeof(unsigned char))};



int pico_cluster_objects(float* rcsq, int n_detections);

int pico_detect_objects(const unsigned char* image, 
                        const int height,
                        const int width, 
                        const int width_step,
                        const unsigned char* cascades, 
                        const int max_detections,
                        const int n_orientations, 
                        const float* orientations,
                        const float scale_factor, 
                        const float stride_factor,
                        const float min_size, 
                        const float q_cutoff,
                        float* rcsq,
                        float* os);

