#import <Foundation/Foundation.h>
#import "PNMacro.h"


/**
 @brief Wrapper class for object which should be passed along with context. item to one of
        CoreFoundation functinos.
 
 @discussion Help to wrap and manage memory usage by object which should be added into context.
             It is possible that object from context has been released at the same time when 
             callback will try to gain access to the object. Wrapper will try to use \c weak
             reference which will protect code from accessing released object.
 
 @author Sergey Mamontov
 @since 3.7.9.2
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNContextInformation : NSObject


#pragma mark Properties

/**
 @brief Stores reference to object which is represented by this wrapper.
 
 @since 3.7.9.2
 */
@property (nonatomic, readonly, pn_desired_weak) id object;


#pragma mark - Class methods

/**
 @brief Construct context holding item.
 
 @param object Reference on object which should be passed as context to one of CoreFoundation 
               API.
 
 @return Constructed and ready to use context object wrapper.
 
 @since 3.7.9.2
 */
+ (instancetype)contextWithObject:(id)object;

#pragma mark -


@end
