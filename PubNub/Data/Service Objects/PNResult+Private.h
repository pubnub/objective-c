/**
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 4.0.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
#import "PNResult.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNResult (Private) <NSCopying>


#pragma mark - Information

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) PNOperationType operation;
@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/**
 * @brief  Stores whether unexpected service data has been passed from parsers.
 */
@property (nonatomic, assign, getter = isUnexpectedServiceData) BOOL unexpectedServiceData;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, nullable, copy) NSString *authKey;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, nullable, copy) NSURLRequest *clientRequest;

/**
 * @brief Stores reference on processed \c response which is ready to use by user.
 *
 * @discussion Content and format for this property different for API. Each method has description about
 *             expected fields and data stored inside.
 */
@property (nonatomic, nullable, copy) NSDictionary<NSString *, id> *serviceData;


#pragma mark - Initialization and configuration

/**
 * @brief Construct result instance in response to successful task completion.
 *
 * @param operation One of \b PNOperationType enum fields to describe what kind of operation has been processed.
 * @param task Reference on data task which has been used to communicate with \b PubNub network.
 * @param processedData Reference on data which has been loaded and pre-processed by corresponding parser.
 * @param error Reference on request processing error.
 *
 * @return Constructed and ready to use result instance.
 */
+ (instancetype)objectForOperation:(PNOperationType)operation
                 completedWithTask:(nullable NSURLSessionDataTask *)task
                     processedData:(nullable NSDictionary<NSString *, id> *)processedData
                   processingError:(nullable NSError *)error;

/**
 * @brief Initialize result instance in response to successful task completion.
 *
 * @param operation One of \b PNOperationType enum fields to describe what kind of operation has been processed.
 * @param task Reference on data task which has been used to communicate with \b PubNub network.
 * @param processedData Reference on data which has been loaded and pre-processed by corresponding parser.
 * @param error Reference on request processing error.
 *
 * @return Initialized and ready to use result instance.
 */
- (instancetype)initForOperation:(PNOperationType)operation
               completedWithTask:(nullable NSURLSessionDataTask *)task
                   processedData:(nullable NSDictionary<NSString *, id> *)processedData
                 processingError:(nullable NSError *)error;

/**
 * @brief Make copy of current result object with mutated data which should be stored in it.
 * @discussion Method can be used to create sub-events (for example one for each message or presence event).
 *
 * @param data Reference on data which should be stored within new instance.
 *
 * @return Copy of receiver with modified data.
 */
- (instancetype)copyWithMutatedData:(nullable id)data;

/**
 * @brief Update data stored for result object.
 *
 * @param data New data which should be placed into result object.
 */
- (void)updateData:(nullable id)data;


#pragma mark - Misc

/**
 * @brief Convert result object to dictionary which can be used to print out structured data
 *
 * @return Object in dictionary representation.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 * @brief Convert result object to string which can be used to print out data
 *
 * @return Stringified object representation.
 */
- (NSString *)stringifiedRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
