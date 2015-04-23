//
//  PNResponseDeserialize.h
//  pubnub
//
//  This class was created to help deserialize
//  responses which connection recieves over the
//  stream opened on sockets.
//  Server returns formatted HTTP headers with response
//  body which should be extracted.
//
//
//  Created by Sergey Mamontov on 12/19/12.
//
//

#import <Foundation/Foundation.h>


@interface PNResponseDeserialize : NSObject


#pragma mark - Instance methods

/**
 @brief De-serialize HTTP raw data from provided read buffer.
 
 @param buffer               Reference on GCD based read buffer from which data should be 
                             de-serialized.
 @param parseCompletionBlock Data processing completion block. Block pass four parameters:
                             \c responses - list of response objects retrieved from read buffer;
                             \c fullBufferLength - full read buffer size; 
                             \c processedBufferLength - how much of bytes from read buffer has 
                             been processed; \c readBufferPostProcessing - read buffer post 
                             processing block which should be called by caller to notify about
                             de-serialization completion.
 
 @since 3.7.10
 */
- (void)parseBufferContent:(dispatch_data_t)buffer
                 withBlock:(void(^)(NSArray *responses, NSUInteger fullBufferLength,
                                    NSUInteger processedBufferLength,
                                    void(^readBufferPostProcessing)(void)))parseCompletionBlock;

#pragma mark -


@end
