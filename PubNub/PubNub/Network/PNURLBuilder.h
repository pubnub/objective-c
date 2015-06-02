#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Class forward

@class PNRequestParameters;


/**
 @brief      \b PubNub API URL builder.
 @discussion Instance allow to translate operation type and parameters to valid URL which should be
             used with request to \b PubNub network.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNURLBuilder : NSObject


///------------------------------------------------
/// @name API URL constructor
///------------------------------------------------

+ (NSURL *)URLForOperation:(PNOperationType)operation
            withParameters:(PNRequestParameters *)parameters;

#pragma mark -


@end
