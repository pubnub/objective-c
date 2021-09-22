/**
 * @brief Header for list of error domains and error codes constants.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef PNErrorCodes_h
#define PNErrorCodes_h

#pragma mark - Error domains

static NSString * const kPNStorageErrorDomain = @"PNStorageErrorDomain";
static NSString * const kPNCBORErrorDomain = @"PNCBORErrorDomain";
static NSString * const kPNAESErrorDomain = @"PNAESErrorDomain";
static NSString * const kPNAPIErrorDomain = @"PNAPIErrorDomain";
static NSString * const kPNAuthErrorDomain = @"PNAuthErrorDomain";


#pragma mark -  General error codes

static NSInteger const kPNUnknownErrorCode = -1;

/**
 * @brief Incomplete or unacceptable set of parameters.
 */
static NSInteger const kPNAPIUnacceptableParameters = 100;


#pragma mark -  Auth

/**
 * @brief Auth token expired.
 */
static NSInteger const kPNAuthPAMTokenExpiredError = 3000;

/**
 * @brief Auth token's UUID doesn't match \c uuid used by \b PubNub instance.
 */
static NSInteger const kPNAuthPAMTokenWrongUUIDError = 3001;


#pragma mark -  Publish

static NSInteger const kPNEmptyMessageError = 4000;


#pragma mark -  AES Error domain codes

static NSInteger const kPNAESEmptyObjectError = 5000;
static NSInteger const kPNAESConfigurationError = 5001;
static NSInteger const kPNAESInsufficientMemoryError = 5002;
static NSInteger const kPNAESEncryptionError = 5003;
static NSInteger const kPNAESDecryptionError = 5004;


#pragma mark -  CBOR Error domain codes

static NSInteger const kPNCBORUnexpectedDataTypeError = 6005;
static NSInteger const kPNCBORMalformedDataError = 6006;
static NSInteger const kPNCBORDataItemNotWellFormedError = 6007;
static NSInteger const kPNCBORMissingDataItemError = 6008;

#endif // PNErrorCodes_h
