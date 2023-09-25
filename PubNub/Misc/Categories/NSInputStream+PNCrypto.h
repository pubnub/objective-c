#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/// `NSInputStream` extension which provides functionality to support crypto module.
@interface NSInputStream (PNCrypto)


#pragma mark - Information

/// Length of data in the stream.
@property(nonatomic, assign) NSUInteger pn_dataLength;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
