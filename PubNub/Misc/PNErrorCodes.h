/**
 @brief Reference header for list of error domains and error codes constants.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef PNErrorCodes_h
#define PNErrorCodes_h

///------------------------------------------------
/// @name Error domains
///------------------------------------------------


static NSString * const kPNAESErrorDomain = @"PNAESErrorDomain";
static NSString * const kPNAPIErrorDomain = @"PNAPIErrorDomain";


///------------------------------------------------
/// @name General error codes
///------------------------------------------------

static NSInteger const kPNUnknownErrorCode = -1;

/**
 @brief Incomplete or unacceptable set of parameters.

 @since 4.0
 */
static NSInteger const kPNAPIUnacceptableParameters = 100;

///------------------------------------------------
/// @name Publish
///------------------------------------------------

static NSInteger const kPNEmptyMessageError = 3000;



///------------------------------------------------
/// @name AES Error domain codes
///------------------------------------------------

static NSInteger const kPNAESEmptyObjectError = 4000;
static NSInteger const kPNAESConfigurationError = 4001;
static NSInteger const kPNAESInsufficientMemoryError = 4002;
static NSInteger const kPNAESDecryptionError = 4003;

#endif // PNErrorCodes_h
