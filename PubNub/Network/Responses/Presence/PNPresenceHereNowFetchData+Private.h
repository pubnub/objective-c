#import <PubNub/PNPresenceHereNowFetchData.h>
#import <PubNub/PNStructures.h>
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Channel presence information private extension.
@interface PNPresenceChannelData (Private) <PNCodable>


#pragma mark - Helpers

/// Presence information details level.
@property(assign, nonatomic, readonly) PNHereNowVerbosityLevel verbosityLevel;

/// Represent presence information as dictionary.
///
/// - Returns: Dictionary representation which depends from presence information details level.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end


#pragma mark - Private interface declaration

/// Here now presence request response private extension.
@interface PNPresenceHereNowFetchData (Private)


#pragma mark - Properties

/// Presence information details level.
@property(assign, nonatomic, readonly) PNHereNowVerbosityLevel verbosityLevel;

/// Index of next page which can be used for ``offset``.
///
/// > Note: `-1` will be returned if there is are more pages.
@property(strong, nonatomic) NSNumber *next;


#pragma mark - Helpers

/// Update channels presence.
///
/// Server response for single channel doesn't contain channel name. This method unify response by setting name.
///
/// - Parameter channelName: Name of the channel for which presence information has been received.
- (void)setPresenceChannel:(NSString *)channelName;

/// Represent presence information as dictionary.
///
/// - Returns: Dictionary representation which depends from presence information details level.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
