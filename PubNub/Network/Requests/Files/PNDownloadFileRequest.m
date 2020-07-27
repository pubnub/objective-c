/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDownloadFileRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNDownloadFileRequest ()


#pragma mark - Information

/**
 * @brief Unique \c file identifier which has been assigned during \c file upload.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Name of channel from which \c file with \c name should be downloaded.
 */
@property (nonatomic, copy) NSString *channel;

/**
 * @brief Name under which uploaded \c file is stored for \c channel.
 */
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c download \c file request.
 *
 * @param channel Name of channel from which \c file with \c name should be downloaded.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return Initialized and ready to use \c download \c file request.
 */
- (instancetype)initWithChannel:(NSString *)channel
                     identifier:(NSString *)identifier
                           name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDownloadFileRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNDownloadFileOperation;
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }

    if (self.channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.channel]
                      forPlaceholder:@"{channel}"];
    } else {
        self.parametersError = [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    }

    if (self.identifier.length) {
        [parameters addPathComponent:self.identifier forPlaceholder:@"{id}"];
    } else {
        self.parametersError = [self missingParameterError:@"identifier"
                                          forObjectRequest:@"Request"];
    }

    if (self.name.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.name]
                      forPlaceholder:@"{name}"];
    } else {
        self.parametersError = [self missingParameterError:@"name" forObjectRequest:@"Request"];
    }

    return parameters;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel
                        identifier:(NSString *)identifier
                              name:(NSString *)name {
    
    return [[self alloc] initWithChannel:channel identifier:identifier name:name];
}

- (instancetype)initWithChannel:(NSString *)channel
                     identifier:(NSString *)identifier
                           name:(NSString *)name {
    
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _channel = [channel copy];
        _name = [name copy];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
