#import "PNServiceData.h"


/**
 @brief  Service data storage class extension to expose private information to subclasses.
 
 @since 4.0
 */
@interface PNServiceData (Private)


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on service response data.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSDictionary *serviceData;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct data object using \b PubNub service response dictionary.
 
 @param response Reference on dictionary which should be stored internally and used by subclasses
                 when give access to entries to the user.
 
 @return Constructed and ready to use service data object.
 
 @since 4.0
 */
+ (instancetype)dataWithServiceResponse:(NSDictionary *)response;

#pragma mark -


@end
