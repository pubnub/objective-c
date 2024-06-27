#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNSubscribeEventData.h>
#import "PNSubscribeCursorData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request response.
@interface PNSubscribeData : PNBaseOperationData


#pragma mark - Properties

/// List with received real-time updates.
@property(strong, nonatomic, readonly) NSArray<PNSubscribeEventData *> *updates;

/// Next subscription cursor.
///
/// The cursor contains information about the start of the next real-time update timeframe.
@property(strong, nonatomic, readonly) PNSubscribeCursorData *cursor;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
