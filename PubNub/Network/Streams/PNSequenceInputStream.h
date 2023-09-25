#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

///Sequence input stream.
///
/// A sequence input stream consists of one or more input streams that are read one after another.
///
/// - Since: 5.1.4
@interface PNSequenceInputStream : NSInputStream


#pragma mark - Information

/// List of input streams.
///
/// Streams will switch one after another when the previous one doesn't have any bytes to read.
@property(nonatomic, readonly, strong) NSArray<NSInputStream *> *streams;

// Overall stream length.
@property(nonatomic, readonly, assign) NSUInteger length;


#pragma mark - Initialization and configuration

/// Create a sequenced input stream.
///
/// - Parameters:
///   - streams: List of input streams that will be represented as one.
///   - lengths: Length of the corresponding input stream in `streams` array.
/// - Returns: Initialized sequence input stream.
/// - Throws: An exception if passed empty list of `streams` or count doesn't match with `lengths`.
+ (instancetype)inputStreamWithInputStreams:(NSArray<NSInputStream *> *)streams
                                    lengths:(NSArray<NSNumber *> *)lengths;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
