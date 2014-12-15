//
//  PNHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/9/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef pn_gcdhelper
    #define pn_gcdhelper 1

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
#endif // pn_gcdhelper


#pragma mark - Public dispatch objects wrapper declaration

@interface PNDispatchObjectWrapper : NSObject

#pragma mark - Properties

/**
 Stores reference on dispatch object for which wrapper has been created.
 */
@property (nonatomic, readonly, pn_dispatch_property_ownership) dispatch_queue_t queue;

/**
 @brief Stores reference on value which stores reference on pointer used during set specific on 
 queue.
 
 @since 3.7.3
 */
@property (nonatomic, readonly, strong) NSValue *specificKeyPointer;


#pragma mark - Class methods

/**
 Construct object wrapper for provided GCD object. 
 
 @note Ownership will be set to wrapper, so there will be no need additionally retain it (in case if
 GCD objects treated as ARC enabled objects).
 @note Main usage for this wrapper defined by cases, when non-structure object can't be stored.
 
 @param object  \a GCD object which should be stored inside wrapper.
 @param pointer Reference on value which store pointer used during set specific operation on queue.
 
 @return Reference on wrapper which will store \a GCD object for us.
 */
+ (PNDispatchObjectWrapper *)wrapperForObject:(dispatch_queue_t)queue specificKey:(NSValue *)pointer;

#pragma mark -


@end


#pragma mark - Public dispatch objects helper declaration

@interface PNDispatchHelper : NSObject


#pragma mark - Class methods

/**
@brief Construct new dispatch queue which won't be bound to any target queue.

@param identifier Identifier of the owner which will be append as prefix to unique queue
identifier.

@warning Caller is responsible for queue retain and release.

@since 3.7.3

@return New non-retained dispatch queue.
*/
+ (dispatch_queue_t)serialQueueWithIdentifier:(NSString *)identifier;

/**
 Perform correct \c 'retain' on dispatch object (till iOS 6.x dispatch objects treated as strucutres).
 
 @param dispatchObject
 Reference on object which should increase it's retain counter.
 */
+ (void)retain:(dispatch_object_t)dispatchObject;

/**
 Perform correct \c 'release' on dispatch object (till iOS 6.x dispatch objects treated as strucutres).
 
 @param dispatchObject
 Reference on object which should decrease it's retain counter.
 */
+ (void)release:(dispatch_object_t)dispatchObject;

#pragma mark -


@end


#pragma mark - Bitwise helper declaration

/**
 Bit which should be placed at the end of bit lists, so va_list will know where it should stop.
 */
static NSUInteger BITS_LIST_TERMINATOR  = ((NSUInteger)0);


@interface PNBitwiseHelper : NSObject


#pragma mark - Class methods

/**
 Clear any bit fields from specified bit field.
 
 @param field
 Reference on bit field from which all bits should be cleared.
 */
+ (void)clear:(unsigned long *)field;

/**
 Verify whether specified mask is in or not specified bit field.
 
 @param field
 Bit field which should be used for inspection.
 
 @param bitMask
 Bit mask which should be used for verification.
 
 @return \c YES in case specified bit mask can be found in specified bit field.
 */
+ (BOOL)is:(unsigned long)field containsBit:(unsigned long)bitMask;

/**
 Verify whether specified set of masks is in or not specified bit field.
 
 @param field
 Bit field which should be used for inspection.
 
 @param bitMask, ...
 List of bitmasks which should be used for verification.
 
 @return \c YES in case specified set of bit masks can be found in specified bit field.
 */
+ (BOOL)is:(unsigned long)field containsBits:(unsigned long)bitMask, ...;

/**
 Verify whether specified mask is in or not specified bit field.
 
 @note This is an extension of +is:containsBit: and allow to specify whether strict rules should be applied or not.
 
 @param field
 Bit field which should be used for inspection.
 
 @param strictly
 Whether specified bit mask containment should respond to \c 'strict' rules.
 
 @param bitMask
 Bit mask which should be used for verification.
 
 @return \c YES in case specified bit mask can be found in specified bit field.
 */
+ (BOOL)is:(unsigned long)field strictly:(BOOL)strictly containsBit:(unsigned long)bitMask;

/**
 Verify whether specified set of masks is in or not specified bit field.
 
 @note This is an extension of +is:... and allow to specify whether strict rules should be applied or not.
 
 @param field
 Bit field which should be used for inspection.
 
 @param strictly
 Whether specified bit mask containment should respond to \c 'strict' rules.
 
 @param bitMask, ...
 List of bitmasks which should be used for verification.
 
 @return \c YES in case specified set of bit masks can be found in specified bit field.
 */
+ (BOOL)is:(unsigned long)field strictly:(BOOL)strictly containsBits:(unsigned long)bitMask, ...;

/**
 Add specified bit mask into bit field.
 
 @param field
 Bit field into which specified bit mask should be added.
 
 @param bitMask
 Mask which should be applied to speified bit field.
 */
+ (void)addTo:(unsigned long *)field bit:(unsigned long)bitMask;

/**
 Add specified set of bit masks into bit field.
 
 @param field
 Bit field into which specified bit mask should be added.
 
 @param bitMask, ..
 Masks which should be applied to speified bit field.
 */
+ (void)addTo:(unsigned long *)field bits:(unsigned long)bitMask, ...;

/**
 Remove specified bit mask from bit field.
 
 @param field
 Bit field from which specified bit mask should be removed.
 
 @param bitMask
 Mask which should be removed from speified bit field.
 */
+ (void)removeFrom:(unsigned long *)field bit:(unsigned long)bitMask;

/**
 Remove specified set of bit masks from bit field.
 
 @param field
 Bit field from which specified bit mask should be removed.
 
 @param bitMask, ...
 Masks which should be removed from speified bit field.
 */
+ (void)removeFrom:(unsigned long *)field bits:(unsigned long)bitMask, ...;

#pragma mark -


@end


#pragma mark - UIApplication replacement helper declaration

@interface PNApplicationHelper : NSObject


#pragma mark - Class methods

/**
 * Will check application Property List file to fetch whether application can run in background or not
 */
+ (BOOL)pn_canRunInBackground;

#pragma mark -


@end


#pragma mark - Helper public interface declaration

@interface PNHelper : NSObject


#pragma mark - Class methods

/**
 Perform correct CoreFoundation object release with pointer nullify.
 
 @param CFObject
 Reference on CF object which should be released and pointer set to \c NULL.
 */
+ (void)releaseCFObject:(CF_RELEASES_ARGUMENT void *)CFObject;

/**
 In case if receiver value not specified, it will return reference on \b NSNull instance.
 
 @param object
 Object against which check should be performed.
 
 @return Passed object if it is not null or \b NSNull instance.
 */
+ (id)nilifyIfNotSet:(id)object;

+ (NSInteger)randomInteger;

/**
 Retrieve reference on globally unique identifier.
 
 @return Generated unique identifier.
 */
+ (NSString *)UUID;

/**
 Compose compressed version from specified UUID string.
 
 @param originalUUID
 Reference on string created with \c +UUID method to compress it.
 
 @return Compressed (shortened) UUID.
 */
+ (NSString *)shortenedUUIDFromUUID:(NSString *)originalUUID;

@end


#pragma mark - Crypto helper declaration

static NSUInteger PN_SHOULD_USE_SIGNATURE = 0;


@interface PNEncryptionHelper : NSObject


#pragma mark - Class methods

/**
 Compose HMAC-SHA256 signature based on provided string and key which should be used for generation.
 
 @param stringForSignature
 Reference on string for which signature shoudl be generated.
 
 @param signatureKey
 Reference on key which should be used for signature generation (salt).
 
 @return encrypted string.
 */
+ (NSString *)HMACSHA256FromString:(NSString *)stringForSignature withKey:(NSString *)signatureKey;

#pragma mark -


@end
