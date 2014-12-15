//
//  PNHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/9/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNHelper.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+PNAdditions.h"


#pragma mark - Public dispatch objects wrapper declaration

@interface PNDispatchObjectWrapper ()

#pragma mark - Properties

@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t queue;
@property (nonatomic, strong) NSValue *specificKeyPointer;


#pragma mark - Instance methods

/**
 Initialize wrapper around provided object.
 
 @param object  \a GCD object which should be stored inside wrapper.
 @param pointer Reference on value which store pointer used during set specific operation on queue.
 
 @return Reference on wrapper which will store \a GCD object for us.
 */
- (id)initWithGCDObject:(dispatch_queue_t)queue specificKey:(NSValue *)pointer;

#pragma mark -


@end


@implementation PNDispatchObjectWrapper : NSObject


#pragma mark - Class methods

+ (PNDispatchObjectWrapper *)wrapperForObject:(dispatch_queue_t)queue specificKey:(NSValue *)pointer {
    
    return (queue ? [[self alloc] initWithGCDObject:queue specificKey:pointer] : nil);
}

- (id)initWithGCDObject:(dispatch_queue_t)queue specificKey:(NSValue *)pointer {
    
    // Check whether initializatino has been successful or not
    if ((self = [super init])) {
        
        self.queue = queue;
        self.specificKeyPointer = pointer;
        [PNDispatchHelper retain:_queue];
    }
    
    
    return self;
}

- (void)dealloc {
    
    [PNDispatchHelper release:_queue];
    _queue = NULL;
}

#pragma mark -


@end


#pragma mark - Public dispatch objects helper implementation

@implementation PNDispatchHelper


#pragma mark - Class methods

+ (dispatch_queue_t)serialQueueWithIdentifier:(NSString *)identifier {

    NSString *queueIdentifier = [NSString stringWithFormat:@"com.pubnub.%@.%@", identifier, [PNHelper UUID]];
    const char *cQueueIdentifier = [queueIdentifier UTF8String];


    return dispatch_queue_create(cQueueIdentifier, DISPATCH_QUEUE_SERIAL);
}

+ (void)retain:(dispatch_object_t)dispatchObject {
    
    pn_dispatch_object_retain(dispatchObject);
}

+ (void)release:(dispatch_object_t)dispatchObject {
    
    pn_dispatch_object_release(dispatchObject);
}

#pragma mark -


@end


#pragma mark - Bitwise helper private interface declaration

@interface PNBitwiseHelper ()


#pragma mark - Class methods

/**
 Compose bitwise mask from values stored in variable list.
 
 @param masksList
 Initialized \c va_list object which store set of flags which should be composed into one at the end.
 
 @return compound mask retrieved from provided list.
 */
+ (unsigned long)compound:(va_list)masksList;

#pragma mark -


@end


#pragma mark - Bitwise helper Implementation

@implementation PNBitwiseHelper


#pragma mark - Class methods

+ (unsigned long)compound:(va_list)masksList {
    
    unsigned long compoundMask = 0;
    unsigned long mask = va_arg(masksList, unsigned long);
    while (mask != BITS_LIST_TERMINATOR) {
        
        compoundMask |= mask;
        mask = va_arg(masksList, unsigned long);
    }
    
    
    return compoundMask;
}

+ (void)clear:(unsigned long *)field {
    
    *field = 0;
}

+ (BOOL)is:(unsigned long)field containsBit:(unsigned long)bitMask {
    
    return [self is:field strictly:NO containsBit:bitMask];
}

+ (BOOL)is:(unsigned long)field containsBits:(unsigned long)bitMask, ... {
    
    va_list bits;
    va_start(bits, bitMask);
    unsigned long compoundMask = (bitMask | [self compound:bits]);
    va_end(bits);
    
    
    return [self is:field strictly:NO containsBit:compoundMask];
}

+ (BOOL)is:(unsigned long)field strictly:(BOOL)strictly containsBit:(unsigned long)bitMask {
    
    return (strictly ? ((field & bitMask) == bitMask) : ((field & bitMask) != 0));
}

+ (BOOL)is:(unsigned long)field strictly:(BOOL)strictly containsBits:(unsigned long)bitMask, ... {
    
    va_list bits;
    va_start(bits, bitMask);
    unsigned long compoundMask = (bitMask | [self compound:bits]);
    va_end(bits);
    
    
    return [self is:field strictly:strictly containsBit:compoundMask];
}

+ (void)addTo:(unsigned long *)field bit:(unsigned long)bitMask {
    
    *field |= bitMask;
}

+ (void)addTo:(unsigned long *)field bits:(unsigned long)bitMask, ... {
    
    va_list bits;
    va_start(bits, bitMask);
    unsigned long compoundMask = (bitMask | [self compound:bits]);
    va_end(bits);
    
    [self addTo:field bit:compoundMask];
}

+ (void)removeFrom:(unsigned long *)field bit:(unsigned long)bitMask {
    
    *field &= ~bitMask;
}

+ (void)removeFrom:(unsigned long *)field bits:(unsigned long)bitMask, ... {
    
    va_list bits;
    va_start(bits, bitMask);
    unsigned long compoundMask = (bitMask | [self compound:bits]);
    va_end(bits);
    
    [self removeFrom:field bit:compoundMask];
}

#pragma mark -


@end


#pragma mark - UIApplication replacement helper declaration

@implementation PNApplicationHelper : NSObject


#pragma mark - Class methods

+ (BOOL)pn_canRunInBackground {
    
    static BOOL canRunInBackground;
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        
        // Retrieve application information Property List
        NSDictionary *applicationInformation = [[NSBundle mainBundle] infoDictionary];
        
        if ([applicationInformation objectForKey:@"UIBackgroundModes"]) {
            
            NSArray *backgroundModes = [applicationInformation valueForKey:@"UIBackgroundModes"];
            NSArray *suitableModes = @[@"audio", @"location", @"voip", @"bluetooth-central", @"bluetooth-peripheral"];
            [backgroundModes enumerateObjectsUsingBlock:^(id mode, NSUInteger modeIdx, BOOL *modeEnumeratorStop) {
                
                canRunInBackground = [suitableModes containsObject:mode];
                *modeEnumeratorStop = canRunInBackground;
            }];
        }
    });
    
    
    return canRunInBackground;
}

#pragma mark -


@end


#pragma mark - Helper private interface declaration

@interface PNHelper ()


#pragma mark - Class methods

/**
 Generate integer which will lie between integers specified by location and length.
 
 @param range
 reference on \b NSRange which describe minimum and maximum values for returned integer.
 
 
 @return Random integer from specified range of values.
 */
+ (NSUInteger)randomIntegerInRange:(NSRange)range;

#pragma mark -


@end



#pragma mark - Helper public interface implementation

@implementation PNHelper


#pragma mark - Class methods

+ (void)releaseCFObject:(CF_RELEASES_ARGUMENT void *)CFObject {
    
    if (CFObject != NULL) {
        
        if (*((CFTypeRef*)CFObject) != NULL) {
            
            CFRelease(*((CFTypeRef*)CFObject));
        }
        
        *((CFTypeRef*)CFObject) = NULL;
    }
}

+ (id)nilifyIfNotSet:(id)object {
    
    return (object ? object : [NSNull null]);
}

+ (NSInteger)randomInteger {
    
    return (arc4random() %(INT32_MAX)-1);
}

+ (NSUInteger)randomIntegerInRange:(NSRange)range {
    
    return range.location + (random() % (range.length - range.location));
}

+ (NSString *)UUID {
    
    // Generating new unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfUUID = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    
    return [(NSString *)CFBridgingRelease(cfUUID) lowercaseString];
}

+ (NSString *)shortenedUUIDFromUUID:(NSString *)originalUUID {
    
    NSMutableString *shortenedUUID = [NSMutableString string];
    
    NSArray *components = [originalUUID componentsSeparatedByString:@"-"];
    [components enumerateObjectsUsingBlock:^(NSString *group, NSUInteger groupIdx, BOOL *groupEnumeratorStop) {
        
        NSRange randomValueRange = NSMakeRange([self randomIntegerInRange:NSMakeRange(0, [group length])], 1);
        [shortenedUUID appendString:[group substringWithRange:randomValueRange]];
    }];
    
    
    return shortenedUUID;
}

#pragma mark -


@end


#pragma mark - Crypto helper implementation

@implementation PNEncryptionHelper


#pragma mark - Class methods

+ (NSString *)HMACSHA256FromString:(NSString *)stringForSignature withKey:(NSString *)signatureKey {
    
    const char *cKey = [signatureKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cSignedData = [stringForSignature cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cSignedData, strlen(cSignedData), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    
    return [HMACData pn_base64Encoding];
}

#pragma mark -


@end
