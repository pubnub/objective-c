#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PubNub+Core.h"


/**
 @brief      Base class which is used to build communication with \b PubNub service and deliver 
             required portion of data to processing methods within client itself.
 @discussion This class used as initial API call point which receive information about remote 
             resource path and parameters required to access it through \b PubNub service.
             After processing this object is used as part of \b PNResult and \b PNStatus to provide
             additional information which may be required during retry / debug stage.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNRequest : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief Represent type of operation which has been issued to \b PubNub service and received
        response stored in \c response and processed response in \c data.

 @since 4.0
 */
@property (nonatomic, readonly, assign) PNOperationType operation;

/**
 @brief Stores reference on path which will be used to get access to \b PubNub services.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *resourcePath;

/**
 @brief Stores reference on query parameters storage which should be passed along with resource
        path.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSDictionary *parameters;

/**
 @brief Stores reference on block which should be called at the end of operation processing.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) PNHandlingBlock completionBlock;

@property (nonatomic, readonly, copy) id(^parseBlock)(id rawData);

#pragma mark -


@end
