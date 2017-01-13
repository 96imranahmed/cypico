#include "pico_wrapper.h"


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
                        float* qs, 
                        float* rs, 
                        float* cs, 
                        float* ss,
                        float* os) {
    int n_detections = 0;
    int n_new_detections = 0;
    int i = 0, k = 0;
    // Scan the image at n_orientations different orientations
    for(i = 0; i < n_orientations; i++) {
        
        n_new_detections = find_objects(orientations[i],
                                        &rs[n_detections], &cs[n_detections],
                                        &ss[n_detections], &qs[n_detections],
                                        max_detections - n_detections,
                                        (void*)cascades, (void*)image, 
				        height, width,
                                        width_step, scale_factor,
                                        stride_factor, min_size,
                                        MIN(height, width), 1);
       
       for (k = 0; k < n_new_detections; k++) {
           os[n_detections + k] = orientations[i];
       }
       
       n_detections += n_new_detections;
    }

    // Given detections of low confidence, we remove them
    for(i = n_detections - 1; i > 0; i--) {
    	if (qs[i] < q_cutoff) {
            os[i] = os[n_detections - 1];
            qs[i] = qs[n_detections - 1];
            rs[i] = rs[n_detections - 1];
            cs[i] = cs[n_detections - 1];
            ss[i] = ss[n_detections - 1];
            n_detections--;
    	}
    }

    return n_detections;
}

