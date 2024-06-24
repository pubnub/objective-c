#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Message action object.
@interface PNMessageAction : NSObject


#pragma mark - Properties

/// What feature this `message action` represents.
@property(copy, nonatomic, readonly) NSString *type;

/// Timetoken (**PubNub**'s high precision timestamp) of `message` for which `action has been added.
@property(strong, nonatomic, readonly) NSNumber *messageTimetoken;

/// `Message action` addition timetoken (**PubNub**'s high precision timestamp).
@property(strong, nonatomic, readonly) NSNumber *actionTimetoken;

/// `Identifier` of user which added this `message action`.
@property(copy, nonatomic, readonly) NSString *uuid;

/// Value which has been added with `message action type`.
@property(copy, nonatomic, readonly) NSString *value;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
