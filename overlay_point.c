/* Pass an overlay-local point through OpenVR.
 *
 * GetTransformForOverlayCoordinates takes HmdVector2_t by value. ctypes
 * on aarch64 does not pass that struct the way the runtime reads it, so
 * this translation unit does the call.
 */
#include <stdint.h>

typedef struct {
    float v[2];
} HmdVector2_t;

typedef int (*GetCoordsFn)(uint64_t handle, int origin, HmdVector2_t coords, float *mat);

int whisper_overlay_point(void *fn, uint64_t handle, int origin,
                          float x, float y, float out[12]) {
    HmdVector2_t coords;
    coords.v[0] = x;
    coords.v[1] = y;
    return ((GetCoordsFn)fn)(handle, origin, coords, out);
}
