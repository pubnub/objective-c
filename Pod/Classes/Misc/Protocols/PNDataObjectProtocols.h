#import <Foundation/Foundation.h>
#import "PNStructures.h"


/**
 @brief      Protocol used to provide access to portion of \c data field structure for \b PNStatus 
             instance object in case if it represent error.
             In most cases this object may represent information related to \b PAM error scope.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNErrorStatusData <NSObject>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  List of channels for which error has been triggered.
 
 @return List of channel names to which client potentially doesn't have access.
 
 @since 4.0
 */
- (NSArray *)channels;

/**
 @brief  List of channel groups for which error has been triggered.
 
 @return List of channel group names to which client potentially doesn't have access.
 
 @since 4.0
 */
- (NSArray *)channelGroups;

/**
 @brief  Service-provided information about error.
 
 @return Stringified issue description.
 
 @since 4.0
 */
- (NSString *)information;

/**
 @brief  Service-provided additional information about error.
 
 @return De-serialized additional information regadring issue.
 
 @since 4.0
 */
- (id)data;

#pragma mark -


@end


/**
 @brief      Protocol used to describe instance suitable to represent service results.
 @discussion Used by \b PubNub class to expose public interface of the instance.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNResult <NSObject>

@optional

///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief Stores HTTP status code with which \c request completed processing with \b PubNub
        service.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign) NSInteger statusCode;

/**
 @brief Represent type of operation which has been issued to \b PubNub service and received
        response stored in \c response and processed response in \c data.

 @since 4.0
 */
@property (nonatomic, readonly, assign) PNOperationType operation;

/**
 @brief  Stores whether secured connection has been used to send request or not.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/**
 @brief  UUID which is currently used by client to identify user on \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 @brief      Authorization which is used to get access to protected remote resources.
 @discussion Some resources can be protected by \b PAM functionality and access done using this 
             authorization key.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *authKey;

/**
 @brief Stores reference on \b PubNub service host name or IP address against which \c request
        has been called.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *origin;

/**
 @brief Stores reference on copy of original request which has been used to fetch or push data
        to \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSURLRequest *clientRequest;

/**
 @brief      Stores reference on processed \c response which is ready to use by user.
 @discussion Content and format for this property different for API. Each method has description
             about expected fields and data stored inside.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) id data;

#pragma mark -


@end


/**
 @brief      Protocol used to describe instance suitable to represent service request processing 
             status.
 @discussion Used by \b PubNub class to expose public interface of the instance.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNStatus <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  One of \b PNStatusCategory fields which provide information about for which status this
         instance has been created.
 
 @return Processing status category.

 @since 4.0
 */
@property (nonatomic, readonly, assign) PNStatusCategory category;

/**
 @brief  Whether status object represent error or not.
 
 @return \c YES in case if status represent request processing error.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isError) BOOL error;

/**
 @brief      Auto-retry configuration information.
 @discussion In most cases client will keep retry request sending till it won't be successful or
             canceled with \c -cancelAutomaticRetry method.
 
 @return \c YES in case if request which represented with this failed status will be resent
         automatically or not.

 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;

/**
 @brief  If not overridden in case of \c isError store \c YES it will store reference on error 
         information.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNErrorStatusData> *data;

#pragma mark -


@end
