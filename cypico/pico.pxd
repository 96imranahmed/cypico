cdef extern from "pico/runtime/picornt.h":
    int find_objects(float* rcsq, 
                     int maxndetections,
                     void* cascade, 
                     float angle,
                     void* pixels, 
                     int nrows, 
                     int ncols, 
                     int ldim,
			         float scalefactor, 
                     float stridefactor, 
                     float minsize, 
                     float maxsize)

cdef extern from "pico_wrapper.h":
    const long FACE_CASCADES_SIZE
    unsigned char* FACE_CASCADES
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
