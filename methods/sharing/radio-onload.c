// Bionic and liblog declarations for the compiler-only NDK installation.
extern void *dlopen(const char *filename, int flags);
extern void *dlsym(void *handle, const char *symbol);
extern char *dlerror(void);
extern int __android_log_print(int priority, const char *tag, const char *format, ...);
extern _Noreturn void _Exit(int status);

enum { RTLD_LOCAL = 0, RTLD_NOW = 2, ANDROID_LOG_INFO = 4, ANDROID_LOG_ERROR = 6 };

// The donor daemon invokes onLoad from MainThread after preparing its Looper.
// Initialize the audio singleton there before the donor publishes its HIDL service.
__attribute__((visibility("default"))) void onLoad(int instance) {
    const char *tag = "C15RadioOnLoad";
    void *radio = dlopen("lib-virtual-modem-radio.so", RTLD_NOW | RTLD_LOCAL);
    if (!radio) {
        __android_log_print(ANDROID_LOG_ERROR, tag, "dlopen: %s", dlerror());
        _Exit(1);
    }

    void (*load_radio)(int) = (void (*)(int))dlsym(radio, "onLoad");
    void *(*audio_focus)(void) =
        (void *(*)(void))dlsym(radio, "_ZN17AudioFocusTracker11getInstanceEv");
    if (!load_radio || !audio_focus) {
        __android_log_print(ANDROID_LOG_ERROR, tag, "Missing donor entry point");
        _Exit(1);
    }

    audio_focus();
    __android_log_print(ANDROID_LOG_INFO, tag, "Audio focus ready on plugin entry thread");
    load_radio(instance);
#ifdef C15_WITH_QTI_IMS
    void *ims = dlopen("lib-virtual-modem-qti-ims.so", RTLD_NOW | RTLD_LOCAL);
    if (!ims) {
        __android_log_print(ANDROID_LOG_ERROR, tag, "IMS dlopen: %s", dlerror());
        _Exit(1);
    }
    int (*load_ims)(int) = (int (*)(int))dlsym(ims, "onLoad");
    if (!load_ims || load_ims(instance) != 0) {
        __android_log_print(ANDROID_LOG_ERROR, tag, "IMS onLoad failed");
        _Exit(1);
    }
    __android_log_print(ANDROID_LOG_INFO, tag, "QTI IMS init returned");
#endif
}
