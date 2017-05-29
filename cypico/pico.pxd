cdef extern from "pico_wrapper.h":
    const unsigned char* MDL_ONE
    const unsigned char* MDL_TWO
    const long* MODELS_LENS
    int pico_cluster_objects(float* rcsq,
                             int n_detections)
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
                            float* os)
