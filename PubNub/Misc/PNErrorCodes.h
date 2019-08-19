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

static NSString * const kPNAESErrorDomain = @"PNAESErrorDomain";
static NSString * const kPNAPIErrorDomain = @"PNAPIErrorDomain";


#pragma mark -  General error codes

static NSInteger const kPNUnknownErrorCode = -1;

/**
 * @brief Incomplete or unacceptable set of parameters.
 */
static NSInteger const kPNAPIUnacceptableParameters = 100;


#pragma mark -  Publish

static NSInteger const kPNEmptyMessageError = 3000;


#pragma mark -  AES Error domain codes

static NSInteger const kPNAESEmptyObjectError = 4000;
static NSInteger const kPNAESConfigurationError = 4001;
static NSInteger const kPNAESInsufficientMemoryError = 4002;
static NSInteger const kPNAESDecryptionError = 4003;

#endif // PNErrorCodes_h
