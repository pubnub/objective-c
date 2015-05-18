/**
 @brief Reference header for list of error domains and error codes constants.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef PNErrorCodes_h
#define PNErrorCodes_h

///------------------------------------------------
/// @name Error domains
///------------------------------------------------

static NSString * const kPNAESErrorDomain = @"PNAESErrorDomain";
static NSString * const kPNPublishErrorDomain = @"PNPublishErrorDomain";


///------------------------------------------------
/// @name General error codes
///------------------------------------------------

static NSInteger const kPNUnknownErrorCode = -1;

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
