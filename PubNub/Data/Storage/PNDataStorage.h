#import <Foundation/Foundation.h>
#import "PNKeyValueStorage.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief \b PubNub client data storage provider.
 *
 * @author Serhii Mamontov
 * @version 4.15.3
 * @since 4.15.3
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDataStorage : NSObject


#pragma mark - Information

/**
 * @brief Storage which is suitable to store various client information which is related to \b PubNub client operation.
 *
 * @discussion Used to store: publish sequence number or latency information.
 */
@property (nonatomic, readonly, strong) id<PNKeyValueStorage> persistentClientData;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c key/value storage for \b PubNub client data.
 *
 * @discussion Used to store: publish sequence number or latency information.
 *
 * @param identifier Unique identifier under which data will be stored (usually portions of publish / subscribed keys).
 *
 * @return Configured and ready to use \c key/value storage for \b PubNub client data.
 */
+ (id<PNKeyValueStorage>)persistentClientDataWithIdentifier:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
