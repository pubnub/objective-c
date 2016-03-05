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
 @copyright © 2009-2016 PubNub, Inc.
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
 */
+ (nullable NSURL *)URLForOperation:(PNOperationType)operation
                     withParameters:(PNRequestParameters *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
