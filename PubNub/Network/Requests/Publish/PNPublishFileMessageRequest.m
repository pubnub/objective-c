#import "PNPublishFileMessageRequest.h"
#import "PNBasePublishRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Publish file message` request private.
@interface PNPublishFileMessageRequest ()


#pragma mark - Properties

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/**
 * @brief Unique identifier provided during file upload.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Name with which uploaded data has been stored.
 */
@property (nonatomic, copy) NSString *filename;


#pragma mark - Initialization and Configuration

/// Initialize `File message publish`  request.
///
/// - Parameters:
///   - channel: Name of channel to which `file message` should be published.
///   - identifier: Unique identifier provided during file upload.
///   - filename Name with which uploaded data has been stored.
/// - Returns: Initialized `publish message` request.
- (instancetype)initWithChannel:(NSString *)channel fileIdentifier:(NSString *)identifier name:(NSString *)filename;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPublishFileMessageRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNPublishFileMessageOperation;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers =[([super headers] ?: @{}) mutableCopy];
    headers[@"Content-Type"] = @"application/json";
    
    return headers;
}

- (id)preFormattedMessage {
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:@{
        @"file": @{ @"id": self.identifier, @"name": self.filename }
    }];
    
    if (self.message) message[@"message"] = self.message;
    
    return message;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/publish-file/%@/%@/0/%@/0/%@",
                          self.publishKey,
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel],
                          self.httpMethod == TransportPOSTMethod ? @"" : [PNString percentEscapedString:self.preparedMessage]);
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel fileIdentifier:(NSString *)identifier name:(NSString *)filename {
    return [[self alloc] initWithChannel:channel fileIdentifier:identifier name:filename];
}

- (instancetype)initWithChannel:(NSString *)channel fileIdentifier:(NSString *)identifier name:(NSString *)filename {
    if ((self = [super initWithChannel:channel])) {
        _identifier = [identifier copy];
        _filename = [filename copy];
    }
    
    return self;
}


#pragma mark - Prepare

- (PNError *)validate {
    PNError *error = [super validate];
    if (error) return error;
    
    if (self.identifier.length == 0) return [self missingParameterError:@"identifier" forObjectRequest:@"Request"];
    if (self.filename.length == 0) return [self missingParameterError:@"filename" forObjectRequest:@"Request"];
    
    return nil;
}

#pragma mark -

@end
