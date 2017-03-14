/**
 @author Sergey Mamontov
 @since 4.5.15
 @copyright © 2009-2017 PubNub, Inc.
 */
#ifndef PNDefines_h
#define PNDefines_h

// Whether iOS/tvOS 10.0, watchOS 3.0 and macOS 10.12 SDK API can be used (project's base SDK set to allow).
#define PN_OS_VERSION_10_SDK_API_AVAILABLE 0
#if (TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_WATCH && __WATCH_OS_VERSION_MAX_ALLOWED >= 30000) || \
    (TARGET_OS_TV && __TV_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_OSX && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101200)
    #undef PN_OS_VERSION_10_SDK_API_AVAILABLE
    #define PN_OS_VERSION_10_SDK_API_AVAILABLE 1
#endif

// Whether iOS/tvOS 10.0, watchOS 3.0 and macOS 10.12 SDK API can be used safely basing on minimum allowed OS
// version which is set in project.
#define PN_OS_VERSION_10_SDK_API_IS_SAFE 0
    #if (TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED >= 100000) || \
    (TARGET_OS_WATCH && __WATCH_OS_VERSION_MIN_REQUIRED >= 30000) || \
    (TARGET_OS_TV && __TV_OS_VERSION_MIN_REQUIRED >= 100000) || \
    (TARGET_OS_OSX && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101200)
    #undef PN_OS_VERSION_10_SDK_API_IS_SAFE
    #define PN_OS_VERSION_10_SDK_API_IS_SAFE 1
#endif

#if PN_OS_VERSION_10_SDK_API_AVAILABLE
    #define PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE 1
    #define PN_OS_UNFAIR_LOCK_AVAILABILE 1
#else
    #define PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE 0
    #define PN_OS_UNFAIR_LOCK_AVAILABILE 0
#endif

#endif // PNDefines_h
