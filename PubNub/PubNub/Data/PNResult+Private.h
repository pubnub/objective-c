/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResult.h"


#pragma mark Class forward

@class PNRequest;


#pragma mark - Private interface declaration

@interface PNResult ()


///------------------------------------------------
/// @name Information
///------------------------------------------------

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) id <NSObject, NSCopying> data;
@property (nonatomic, strong) PNRequest *operation;


///------------------------------------------------
/// @name Initialization and configuration
///------------------------------------------------

+ (instancetype)resultFor:(PNRequest *)operation withResponse:(NSURLResponse *)response
                  andData:(id <NSObject, NSCopying>)data;
- (instancetype)initFor:(PNRequest *)operation withResponse:(NSURLResponse *)response
                andData:(id <NSObject, NSCopying>)data;

#pragma mark -


@end
