/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBasePublishRequest+Private.h"
#import "PNPublishFileMessageRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNPublishFileMessageRequest ()


#pragma mark - Information

/**
 * @brief Unique identifier provided during file upload.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Name with which uploaded data has been stored.
 */
@property (nonatomic, copy) NSString *filename;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c file \c message \c publish  request.
 *
 * @param channel Name of channel to which \c file \c message should be published.
 * @param identifier Unique identifier provided during file upload.
 * @param filename Name with which uploaded data has been stored.
 *
 * @return Initialized and ready to use \c publish \c message request.
 */
- (instancetype)initWithChannel:(NSString *)channel
                 fileIdentifier:(NSString *)identifier
                           name:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPublishFileMessageRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNPublishFileMessageOperation;
}

- (id)preFormattedMessage {
    NSMutableDictionary *message = [NSMutableDictionary new];
    
    if (self.message) {
        message[@"message"] = self.message;
    }
    
    if (self.identifier.length && self.filename.length) {
        message[@"file"] = @{
            @"id": self.identifier,
            @"name": self.filename
        };
    } else if (!self.identifier.length) {
        self.parametersError = [self missingParameterError:@"identifier"
                                          forObjectRequest:@"Request"];
    } else if (!self.filename.length) {
        self.parametersError = [self missingParameterError:@"filename"
                                          forObjectRequest:@"Request"];
    }
    
    return !self.parametersError ? message : nil;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel
                    fileIdentifier:(NSString *)identifier
                              name:(NSString *)filename {
    
    return [[self alloc] initWithChannel:channel fileIdentifier:identifier name:filename];
}

- (instancetype)initWithChannel:(NSString *)channel
                 fileIdentifier:(NSString *)identifier
                           name:(NSString *)filename {
    
    if ((self = [super initWithChannel:channel])) {
        _identifier = [identifier copy];
        _filename = [filename copy];
    }
    
    return self;
}

#pragma mark -

@end
