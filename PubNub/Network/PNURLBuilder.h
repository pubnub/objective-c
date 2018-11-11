#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Class forward

@class PNRequestParameters;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub API URL builder.
 @discussion Instance allow to translate operation type and parameters to valid URL which should be
             used with request to \b PubNub network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNURLBuilder : NSObject


///------------------------------------------------
/// @name API URL constructor
///------------------------------------------------

/**
 @brief  Construct request URL basing on operation type and list of request parameters.
 
 @param operation  One of \b PNOperationType fields which describes operation type (to choose correct API 
                   endpoint).
 @param parameters Object which represent set of parameters which should be used during path composition.
 
 @return URL to perform required by \c operation API call.
 */
+ (nullable NSURL *)URLForOperation:(PNOperationType)operation
                     withParameters:(PNRequestParameters *)parameters;


///------------------------------------------------
/// @name API URL verificator
///------------------------------------------------

/**
 @brief  Check whether passed URL represent call to API described by passed \c operation.
 
 @since 4.5.0
 
 @param url        Previously generated API call URL which should be used during verification.
 @param operation  One of \b PNOperationType fields which describes operation type against which verification will be done.
 
 @return \c YES in case if passed \c url is for API which described by \c operation.
 */
+ (BOOL)isURL:(NSURL *)url forOperation:(PNOperationType)operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
