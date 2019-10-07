/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNMessageAction+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMessageAction ()


#pragma mark - Information

/**
 * @brief What feature this \c message \c action represents.
 */
@property (nonatomic, copy) NSString *type;

/**
 * @brief Timetoken (\b PubNub's high precision timestamp) of \c message for which \c action has
 * been added.
 */
@property (nonatomic, strong) NSNumber *messageTimetoken;

/**
 * @brief \c Message \c action addition timetoken (\b PubNub's high precision timestamp).
 */
@property (nonatomic, strong) NSNumber *actionTimetoken;

/**
 * @brief \c Identifier of user which added this \c message \c action.
 */
@property (nonatomic, copy) NSString *uuid;

/**
 * @brief Value which has been added with \c message \c action \b type.
 */
@property (nonatomic, copy) NSString *value;


#pragma mark - Misc

/**
 * @brief Translate \c message \c action data model to dictionary.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMessageAction


#pragma mark - Initialization & Configuration

+ (instancetype)actionFromDictionary:(NSDictionary *)data {
    PNMessageAction *action = [self new];
    action.value = data[@"value"];
    action.uuid = data[@"uuid"];
    action.actionTimetoken = data[@"actionTimetoken"];
    action.messageTimetoken = data[@"messageTimetoken"];
    action.type = data[@"type"];
    
    return action;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"type": self.type,
        @"uuid": self.uuid,
        @"actionTimetoken": self.actionTimetoken,
        @"messageTimetoken": self.messageTimetoken,
        @"value": self.value
    };
}

- (NSString *)debugDescription {
    return [[self dictionaryRepresentation] description];
}

#pragma mark -


@end
