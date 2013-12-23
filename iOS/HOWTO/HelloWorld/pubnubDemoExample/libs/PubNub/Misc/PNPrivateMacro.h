//
//  PNPrivateMacro.h
//  pubnub
//
//  Created by Sergey Mamontov on 8/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+PNAdditions.h"


#ifndef PNPrivateMacro_h
#define PNPrivateMacro_h


#pragma mark - Cypher

#define PN_SHOULD_USE_SIGNATURE 0


#pragma mark - GCD helper macro

#ifndef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
    #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 0

    #if __IPHONE_OS_VERSION_MIN_REQUIRED
        // Only starting from iOS 6.x GCD structures treated as objects and handled by ARC
        #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
            #undef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
            #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 1
        #endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    #else
        // Only starting from Mac OS X 10.8.x GCD structures treated as objects and handled by ARC
        #if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
            #undef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
            #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 1
        #endif // MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
    #endif // __IPHONE_OS_VERSION_MIN_REQUIRED

    #ifdef OS_OBJECT_USE_OBJC
        #if OS_OBJECT_USE_OBJC == 0
            #undef PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
            #define PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS 0
        #endif
    #endif
#endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS

#ifndef pn_dispatch_property_ownership
    #define pn_dispatch_property_ownership assign

    #if PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
        #undef pn_dispatch_property_ownership
        #define pn_dispatch_property_ownership strong
    #endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
#endif // pn_dispatch_property_ownership

#ifndef pn_dispatch_object_memory_management
    #define pn_dispatch_object_memory_management

    #if PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
        #define pn_dispatch_object_retain(__OBJECT__)
        #define pn_dispatch_object_release(__OBJECT__)
    #else
        #define pn_dispatch_object_retain(__OBJECT__) dispatch_retain(__OBJECT__)
        #define pn_dispatch_object_release(__OBJECT__) dispatch_release(__OBJECT__)
    #endif // PN_DISPATCH_STRUCTURES_TREATED_AS_OBJECTS
#endif // pn_dispatch_object_memory_management




#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

#pragma mark - GCD helper functions

static void PNDispatchRetain(dispatch_object_t object);
void PNDispatchRetain(dispatch_object_t object) {

    pn_dispatch_object_retain(object);
}

static void PNDispatchRelease(dispatch_object_t object);
void PNDispatchRelease(dispatch_object_t object) {

    pn_dispatch_object_release(object);
}


#pragma mark - Bitwise helper functions

#define BITS_LIST_TERMINATOR ((NSUInteger)0)


static unsigned long PNBitCompound(va_list masksList);
unsigned long PNBitCompound(va_list masksList) {

    unsigned long compoundMask = 0;
    unsigned long mask = va_arg(masksList, unsigned long);
    while (mask != BITS_LIST_TERMINATOR) {

        compoundMask |= mask;
        mask = va_arg(masksList, unsigned long);
    }
    va_end(masksList);


    return compoundMask;
}

static void PNBitClear(unsigned long *flag);
void PNBitClear(unsigned long *flag) {

    *flag = 0;
}

static BOOL PNBitStrictIsOn(unsigned long flag, unsigned long mask);
BOOL PNBitStrictIsOn(unsigned long flag, unsigned long mask) {

    return (flag & mask) == mask;
}


static BOOL PNBitIsOn(unsigned long flag, unsigned long mask);
BOOL PNBitIsOn(unsigned long flag, unsigned long mask) {

    return (flag & mask) != 0;
}

static BOOL PNBitsIsOn(unsigned long flag, BOOL allMasksRequired, ...);
BOOL PNBitsIsOn(unsigned long flag, BOOL allMasksRequired, ...) {

    va_list bits;
    va_start(bits, allMasksRequired);
    unsigned long compoundMask = PNBitCompound(bits);


    return allMasksRequired ? (flag & compoundMask) == compoundMask : (flag & compoundMask) != 0;
}

static void PNBitOn(unsigned long *flag, unsigned long mask);
void PNBitOn(unsigned long *flag, unsigned long mask) {

    *flag |= mask;
}

static void PNBitsOn(unsigned long *flag, ...);
void PNBitsOn(unsigned long *flag, ...) {

    va_list bits;
    va_start(bits, flag);
    unsigned long compoundMask = PNBitCompound(bits);

    PNBitOn(flag, compoundMask);
}

static void PNBitOff(unsigned long *flag, unsigned long mask);
void PNBitOff(unsigned long *flag, unsigned long mask) {

    *flag &= ~mask;
}

static void PNBitsOff(unsigned long *flag, ...);
void PNBitsOff(unsigned long *flag, ...) {

    va_list bits;
    va_start(bits, flag);
    unsigned long compoundMask = PNBitCompound(bits);

    PNBitOff(flag, compoundMask);
}


#pragma mark - CoreFoundation helper functions

static void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject);
void PNCFRelease(CF_RELEASES_ARGUMENT void *CFObject) {
    if (CFObject != NULL) {

        if (*((CFTypeRef*)CFObject) != NULL) {

            CFRelease(*((CFTypeRef*)CFObject));
        }

        *((CFTypeRef*)CFObject) = NULL;
    }
}

static NSNull* PNNillIfNotSet(id object);
NSNull* PNNillIfNotSet(id object) {

    return (object ? object : [NSNull null]);
}


#pragma mark - Misc functions

static NSUInteger PNRandomValueInRange(NSRange valuesRange);
NSUInteger PNRandomValueInRange(NSRange valuesRange) {

    return valuesRange.location + (random() % (valuesRange.length - valuesRange.location));
}

static NSString* PNUniqueIdentifier();
NSString* PNUniqueIdentifier() {

    // Generating new unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfUUID = CFUUIDCreateString(kCFAllocatorDefault, uuid);

    // release the UUID
    CFRelease(uuid);


    return [(NSString *)CFBridgingRelease(cfUUID) lowercaseString];
}

static NSString* PNShortenedIdentifierFromUUID(NSString *uuid);
NSString* PNShortenedIdentifierFromUUID(NSString *uuid) {

    NSMutableString *shortenedUUID = [NSMutableString string];

    NSArray *components = [uuid componentsSeparatedByString:@"-"];
    [components enumerateObjectsUsingBlock:^(NSString *group, NSUInteger groupIdx, BOOL *groupEnumeratorStop) {

        NSRange randomValueRange = NSMakeRange(PNRandomValueInRange(NSMakeRange(0, [group length])), 1);
        [shortenedUUID appendString:[group substringWithRange:randomValueRange]];
    }];


    return shortenedUUID;
}

static NSString *PNHMACSHA256String(NSString *key, NSString *signedData);
NSString *PNHMACSHA256String(NSString *key, NSString *signedData) {

    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cSignedData = [signedData cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cSignedData, strlen(cSignedData), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];


    return [HMACData base64Encoding];
}

static BOOL PNIsUserGeneratedUUID(NSString *uuid);
BOOL PNIsUserGeneratedUUID(NSString *uuid) {

    NSString *uuidSearchRegex = @"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}";
    NSPredicate *generatedUUIDCheckPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", uuidSearchRegex];


    return ![generatedUUIDCheckPredicate evaluateWithObject:uuid];
}

static NSInteger PNRandomInteger();
NSInteger PNRandomInteger() {

    return (arc4random() %(INT32_MAX)-1);
}

#pragma clang diagnostic pop

#endif // PNPrivateMacro_h
