/**
 Extending \b PNWhereNow class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNWhereNow.h"


#pragma mark Private interface declaration

@interface PNWhereNow ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSArray *channels;


#pragma mark - Class methods

/**
 Construct and initialize object which holds information about client identifier and channels at which it reside at
 this moment.

 @param clientIdentifier
 Client identifier for which service returned list of channels.

 @param channels
 List of \b PNChannel instances for which specified client identifier subscribed at this moment.

 @return Ready to use \b PNWhereNow instance.
 */
+ (PNWhereNow *)whereNowForClientIdentifier:(NSString *)clientIdentifier andChannels:(NSArray *)channels;


#pragma mark - Instance methods

/**
 Initialize instance with client identifier and set of channels at which it subscribed.

 @param clientIdentifier
 Client identifier for which service returned list of channels.

 @param channels
 List of \b PNChannel instances for which specified client identifier subscribed at this moment.

 @return Initialized \b PNWhereNow instance.
 */
- (id)initWithClientIdentifier:(NSString *)clientIdentifier andChannels:(NSArray *)channels;

#pragma mark -


@end
