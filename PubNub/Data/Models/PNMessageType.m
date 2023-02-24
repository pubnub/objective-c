/**
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 5.2.0
 * @copyright © 2010-2022 PubNub Inc. All Rights Reserved.
 */
#import "PNMessageType+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMessageType () <NSCopying>

/**
 * @brief One of types associated with message when it has been published.
 *
 * @discussion This property may store \b PubNub defined types (like: message, signal, file, object, messageAction
 */
@property(nonatomic, copy) NSString *value;


#pragma mark - Initialization and configuration

/**
 * @brief Create and configure instance from actual value.
 *
 * @param value Custom user type of stringified \b PubNub provided type.
 */
- (instancetype)initWithValueFromString:(NSString *)value NS_DESIGNATED_INITIALIZER;


#pragma mark - Helper

/**
 * @brief Transform provided data to string.
 *
 * @param userType User-provided type which should be used for message type.
 * @param pnType \b PubNub provided message type which should be stringified.
 *
 * @return Proper message type which will be used by user and publish endpoints.
 */
+ (NSString *)valueFromUserType:(nullable NSString *)userType
              pubNubMessageType:(PNServiceMessageType)pnType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNMessageType


#pragma mark - Initialization and configuration

+ (instancetype)messageTypeFromString:(NSString *)type {
    return [self messageTypeFromString:type pubNubMessageType:PNRegularMessageType];
}

+ (instancetype)messageTypeFromString:(NSString *)userType pubNubMessageType:(PNServiceMessageType)pnType {
    return [[self alloc] initWithValueFromString:[self valueFromUserType:userType pubNubMessageType:pnType]];
}

- (instancetype)init {
    NSDictionary *errorInformation = @{ NSLocalizedRecoverySuggestionErrorKey: @"Use provided constructor" };
    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:errorInformation];
    
    return nil;
}

- (instancetype)initWithValueFromString:(NSString *)value {
    if ((self = [super init])) {
        _value = [value copy];
    }
    
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[PNMessageType alloc] initWithValueFromString:self.value];
}


#pragma mark - Helper

- (BOOL)isEqual:(id)other {
    return other && [other isKindOfClass:[self class]] ? [self isEqualToMessageType:other] : NO;
}

- (BOOL)isEqualToMessageType:(PNMessageType *)otherMessageType {
    return [self.value isEqualToString:otherMessageType.value];
}

+ (NSString *)valueFromUserType:(NSString *)userMessageType pubNubMessageType:(PNServiceMessageType)pubNubMessageType {
    static NSArray<NSString *> *_pubNubMessageTypeMap;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _pubNubMessageTypeMap = @[@"pn_message", @"pn_signal", @"pn_object", @"pn_messageAction", @"pn_file"];
    });

    return userMessageType.length ? userMessageType : _pubNubMessageTypeMap[pubNubMessageType];
}

#pragma mark -


@end
