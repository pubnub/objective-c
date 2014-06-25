#import <Foundation/Foundation.h>


/**
 This class allow to get access to result of 'Where now' API and find out to which channel client (specified by \c
 identifier property) subscribed at this moment.

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNWhereNow : NSObject


#pragma mark - Properties

/**
 Stores reference on client identifier for which channels search has been performed.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 Stores list of channels at which specified client subscribed at this moment.
 */
@property (nonatomic, readonly, strong) NSArray *channels;

#pragma mark -


@end
