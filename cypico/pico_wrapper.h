#pragma once
#include <math.h>
#include "cypico/pico/runtime/picort.h"

#ifndef MIN
    #define MIN(a, b) ((a)<(b)?(a):(b))
#endif

static const unsigned char FACE_CASCADES[] =
{
    #include "cypico/pico/runtime/cascades/facefinder.ea"
};
static const long FACE_CASCADES_SIZE = (long) (sizeof(FACE_CASCADES) / sizeof(unsigned char));


int pico_detect_objects(const unsigned char* image, const int height,
                        const int width, const int width_step,
                        const unsigned char* cascades, const int max_detections,
                        const int n_orientations, const float* orientations,
                        const float scale_factor, const float stride_factor,
                        const float min_size, const float q_cutoff,
                        float* qs, float* rs, float* cs, float* ss, float* os);

