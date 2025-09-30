#import "PNOperationResult+Private.h"
#import "PNPrivateStructures.h"
#import "PNStatus+Private.h"
#import "PNDictionary.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation (request or client generated) status object private extension.
@interface PNStatus (Private)


#pragma mark - Initialization and configuration

/// Initialize operation status object.
///
/// - Parameters:
///   - operation: Type of operation for which status object has been created.
///   - category: Operation processing status category.
///   - response: Processed operation outcome data object.
/// - Returns: Initialized operation status object.
- (instancetype)initWithOperation:(PNOperationType)operation
                         category:(PNStatusCategory)category
                         response:(nullable id)response;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    @throw [NSException exceptionWithName:@"PNStatus statusDataClass"
                                   reason:@"Not implemented by subclass"
                                 userInfo:nil];
}

- (NSString *)stringifiedCategory {
    return PNStatusCategoryStrings[self.category];
}

- (void)updateCategory:(PNStatusCategory)category {
    self.category = category;
}

- (void)setCategory:(PNStatusCategory)category {
    _category = category;
    
    if (_category == PNDecryptionErrorCategory || _category == PNBadRequestCategory) self.error = YES;
    else if (_category == PNConnectedCategory || _category == PNReconnectedCategory ||
             _category == PNDisconnectedCategory || _category == PNUnexpectedDisconnectCategory) {
        
        self.error = NO;
    }
}


#pragma mark - Initialization and Configuration

+ (instancetype)objectWithOperation:(PNOperationType)operation 
                           category:(PNStatusCategory)category
                           response:(id)response {
    return [[self alloc] initWithOperation:operation category:category response:response];
}

- (instancetype)initWithOperation:(PNOperationType)operation category:(PNStatusCategory)category response:(id)response {
    if ((self = [super initWithOperation:operation response:response])) {
        _category = category;
        
        if (_category == PNConnectedCategory || _category == PNReconnectedCategory ||
            _category == PNDisconnectedCategory || _category == PNUnexpectedDisconnectCategory ||
            _category == PNCancelledCategory || _category == PNAcknowledgmentCategory) {
            _error = NO;
        } else if (_category != PNUnknownCategory) _error = YES;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PNStatus *status = [super copyWithZone:zone];
    status.requireNetworkAvailabilityCheck = self.requireNetworkAvailabilityCheck;
    status.category = self.category;
    status.subscribedChannels = self.subscribedChannels;
    status.subscribedChannelGroups = self.subscribedChannelGroups;
    status.error = self.isError;
    status.currentTimetoken = self.currentTimetoken;
    status.lastTimeToken = self.lastTimeToken;
    status.currentTimeTokenRegion = self.currentTimeTokenRegion;
    status.lastTimeTokenRegion = self.lastTimeTokenRegion;

    return status;
}

#pragma mark -


@end
