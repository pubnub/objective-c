#import "PubNub.h"
#import "PNChannelProtocol.h"

/**
 Base class extension which provide methods for access rights manipulation.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (PAM)


#pragma mark - Class (singleton) methods

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:' or "
                         "'-changeApplicationAccessRightsTo:onPeriod:' with PNReadAccessRight to grant read-only "
                           "access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +grantReadAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10
                         andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read-only access right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:' with PNWriteAccessRight to grant write-only "
                           "access right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +grantWriteAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10
                          andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write-only access right. Class method will be removed in "
                           "future.");

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightForApplicationAtPeriod:10];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:' with PNAllAccessRight to grant read and write"
                           " access rights. Class method will be removed in future.");

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForApplication: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightForApplicationAtPeriod:10
                        andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +grantReadAccessRightForApplicationAtPeriod:andCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNAllAccessRight to grant read and write access rights. Class method will be removed in "
                           "future.");

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub revokeAccessRightsForApplication];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see PNError class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class

 @see +revokeAccessRightsForApplicationWithCompletionHandlingBlock:

 @see +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)revokeAccessRightsForApplication
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:' with PNNoAccessRights to revoke access rights"
                           " (duration will be ignored). Class method will be removed in future.");

/**
 @brief Alter application level access rights (based on subscription key).
 
 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                     subscribeKey:@"demo" secretKey:@"my-secret-key"]];
 [PubNub connect];
 [PubNub changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:10];
 [PubNub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes even despite the fact that channel configured only for \a 'write' access rights. It happens because application
 access rights has higher priority against channel based access rights.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self 
                                                          withBlock:^(PNAccessRightsCollection *collection,
                                                                      PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.
 
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on application 
                             level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value
      (default value is \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter application level access rights (based on subscription key).
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:10
              andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 [pubnub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes even despite the fact that channel configured only for \a 'write' access rights. It happens because application
 access rights has higher priority against channel based access rights.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, 
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.
 
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on application 
                             level.
 @param handlerBlock         The block which will be called by \b PubNub client when one of success or error events will 
                             be received. The block takes two arguments: \c collection - \b PNAccessRightsCollection 
                             instance which hold set of \b PNAccessRightsInformation instances to describe new 
                             \a 'application' access rights; \c error - error which describes what exactly went wrong
                             during access rights change. Always check \a error.code to find out what caused error 
                             (check PNErrorCodes header file and use \a -localizedDescription / 
                             \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable 
                             description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value
      (default value is \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
             andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForApplication and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application.
     }
     else {

         // PubNub client did fail to revoke access rights from application.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see PNError class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNAccessRightsInformation class

 @see PNObservationCenter class

 @see +revokeAccessRightsForApplication

 @see +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' or "
                           "'-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored). Class method will be "
                           "removed in future.");
/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNReadAccessRight to grant read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'channel' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'channel' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNReadAccessRight "
                           "to grant read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator"];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNReadAccessRight to grant "
                           "read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time. 
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator" 
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read-only access right. Class method will be removed in "
                           "future.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNReadAccessRight to grant read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForApplicationAtPeriod:
 */
+ (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNReadAccessRight to"
                           " grant read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"spectator", @"visitor"]];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor' 
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:clients:withCompletionHandlingBlock:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNReadAccessRight to grant "
                           "read-only access right. Class method will be removed in future.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a +grantReadAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantReadAccessRightForChannel:forPeriod:client:

 @see +grantWriteAccessRightForChannel:forPeriod:
 */
+ (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read-only access right. Class method will be removed in "
                           "future.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting,
 \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:withCompletionHandlingBlock:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or "
                           "'-changeAccessRightsFor:to:onPeriod:' with PNWriteAccessRight to grant write-only access "
                           "right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting, \b PubNub client allowed to post
 subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNWriteAccessRight "
                           "to grant write-only access right. Class method will be removed in future.");

+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNWriteAccessRight to grant "
                           "write-only access right. Class method will be removed in future.");
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write-only access right. Class method will be removed in "
                           "future.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannels:forPeriod:withCompletionHandlingBlock:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or "
                           "'-changeAccessRightsFor:to:onPeriod:' with PNWriteAccessRight to grant write-only access "
                           "right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
              withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                  if (error == nil) {

                      // PubNub client successfully changed access rights for 'channel' access level.
                  }
                  else {
 
                      // PubNub client did fail to revoke access rights from 'channel' access level.
                      //
                      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                      // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                      // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                      // has been requested.
                  }
 }];
 [PubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannels:forPeriod:

 @see +grantReadAccessRightForApplicationAtPeriod:
 */
+ (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNWriteAccessRight "
                           "to grant write-only access right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow subscription on \a 'iosdev' channel for clients with \a 'spectator' and \a 'visitor'
 authorization keys for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:clients:withCompletionHandlingBlock:

 @see +grantReadAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNWriteAccessRight to grant "
                           "write-only access right. Class method will be removed in future.");

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a +grantWriteAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setupWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                    andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'user' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'user' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.5.3

 @see PNConfiguration class

 @see PNChannel class

 @see PNAccessRightOptions class

 @see PNAccessRightsCollection class

 @see PNObservationCenter class
 
 @see +grantWriteAccessRightForChannel:forPeriod:clients:

 @see +grantReadAccessRightForChannel:forPeriod:
 */
+ (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write-only access right. Class method will be removed in "
                           "future.");

+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNAllAccessRights to grant read and write access rights. Class method will be removed in "
                           "future.");
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNAllAccessRights to"
                           " grant read and write access rights. Class method will be removed in future.");
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNAllAccessRights to grant and"
                           " write access rights. Class method will be removed in future.");
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNAllAccessRights to grant and write access rights. Class method will be removed in "
                           "future.");
+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNAllAccessRights to grant read and write access rights. Class method will be removed in "
                           "future.");
+ (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNAllAccessRights to"
                           " grant read and write access rights. Class method will be removed in future.");
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNAllAccessRights to grant and"
                           " write access rights. Class method will be removed in future.");
+ (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNAllAccessRights to grant and write access rights. Class method will be removed in "
                           "future.");

+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored). Class method will be "
                           "removed in future.");


/**
 Revoke all access rights on whole \a 'channel' level.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannel: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannel:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNNoAccessRights to "
                           "revoke access rights (duration will be ignored). Class method will be removed in future.");
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNNoAccessRights to revoke "
                           "access rights (duration will be ignored). Class method will be removed in future.");

/**
 Revoke all access rights on \a 'user' level. Access rights will be revoked for specific user on specific channel.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannel:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [PubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights for user at channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights for user at channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client should revoke all access rights on specific user \c clientAuthorizationKey.

 @param clientAuthorizationKey
 \a NSString instance which holds client authorization key from which access rights should be revoked.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannel:client:

 @see \a +grantAllAccessRightsForChannel:forPeriod:clients:
 */
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored). Class method will be "
                           "removed in future.");
+ (void)revokeAccessRightsForChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:' or '-changeAccessRightsFor:to:onPeriod:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored). Class method will be "
                           "removed in future.");

/**
 Revoke all access rights on whole \a 'channel' level. This method allow to revoke access rights for the set of \b
 PNChannel instances.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannels: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [PubNub revokeAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channels
 List of \b PNChannel instances from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +revokeAccessRightsForChannels:

 @see \a +grantAllAccessRightsForChannel:forPeriod:clients:
 */
+ (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' or "
                           "'-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with PNNoAccessRights to "
                           "revoke access rights (duration will be ignored). Class method will be removed in future.");
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:' or "
                           "'-changeAccessRightsForClients:object:to:onPeriod:' with PNNoAccessRights to revoke "
                           "access rights (duration will be ignored). Class method will be removed in future.");
+ (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' or"
                           " '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored). Class method will be "
                           "removed in future.");

/**
 @brief Alter channel(s) level access rights.
 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                     subscribeKey:@"demo" secretKey:@"my-secret-key"]];
 [PubNub connect];
 [PubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]]
                            to:PNReadAccessRight onPeriod:10];
 [PubNub changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:10];
 @endcode
 
 
 Code above configure access rights in a way, which will allow to subscribe and post messages to \a 'iosdev', 
 \a 'androiddev' and \a 'macosdev' channels for \b 10 minutes even despite the fact that channels configured only for
 \a 'read' access rights. It happens because application access rights has higher priority against channel based access
 rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self 
                                                          withBlock:^(PNAccessRightsCollection *collection,
                                                                      PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param channelObjects       List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                             \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which access rights 
                             should be changed
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on channel level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter channel(s) level access rights.
 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                     subscribeKey:@"demo" secretKey:@"my-secret-key"]];
 [PubNub connect];
 [PubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]]
                            to:PNReadAccessRight onPeriod:10
   withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 [PubNub changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:10];
 @endcode
 
 
 Code above configure access rights in a way, which will allow to subscribe and post messages to \a 'iosdev', 
 \a 'androiddev' and \a 'macosdev' channels for \b 10 minutes even despite the fact that channels configured only for
 \a 'read' access rights. It happens because application access rights has higher priority against channel based access
 rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self 
                                                          withBlock:^(PNAccessRightsCollection *collection,
                                                                      PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param channelObjects       List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                             \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which access rights 
                             should be changed
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on channel level.
 @param handlerBlock         The block which will be called by \b PubNub client when one of success or error events will 
                             be received. The block takes two arguments: \c collection - \b PNAccessRightsCollection 
                             instance which hold set of \b PNAccessRightsInformation instances to describe new 
                             \a 'channel' access rights; \c error - error which describes what exactly went wrong during
                             access rights change. Always check \a error.code to find out what caused error (check 
                             PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
                             \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 @brief Alter channel(s) level access rights.
 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                     subscribeKey:@"demo" secretKey:@"my-secret-key"]];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"spectator", @"visitor"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [PubNub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode
 
 Code above allow to subscribe and post messages to \a 'iosdev' channel even for \a 'spectator' and \a 'visitor' users.
 It happens because channel access rights has higher priority against user based access rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self 
                                                          withBlock:^(PNAccessRightsCollection *collection,
                                                                      PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param clientsAuthorizationKeys List of \a NSString instances which specify list of client for which access rights 
                                 should be changed.
 @param object                   List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on channel 
                                 level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter channel(s) level access rights.
 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                     subscribeKey:@"demo" secretKey:@"my-secret-key"]];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"spectator", @"visitor"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

      if (error == nil) {

          // PubNub client successfully changed access rights for 'user' access level.
      }
      else {

          // PubNub client did fail to revoke access rights from 'user' access level.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
          // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human  readable 
          // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
          // access level for which change has been requested.
      }
 }];
 [pubNub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode
 
 Code above allow to subscribe and post messages to \a 'iosdev' channel even for \a 'spectator' and \a 'visitor' users.
 It happens because channel access rights has higher priority against user based access rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsChangeObserver:self 
                                                          withBlock:^(PNAccessRightsCollection *collection,
                                                                      PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param clientsAuthorizationKeys List of \a NSString instances which specify list of client for which access rights 
                                 should be changed.
 @param object                   List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on channel 
                                 level.
 @param handlerBlock             The block which will be called by \b PubNub client when one of success or error events
                                 will be received. The block takes two arguments: \c collection -
                                 \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation 
                                 instances to describe new \a 'user' access rights; \c error - error which describes 
                                 what exactly went wrong during access rights change. Always check \a error.code to find
                                 out what caused error (check PNErrorCodes header file and use 
                                 \a -localizedDescription / \a -localizedFailureReason and 
                                 \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
+ (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Audit access rights for \a 'application' level. \a 'application' level is top-layer of access rights tree which will
 also provide information about it's child levels: \a 'channel' and \a 'user' levels.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [PubNub auditAccessRightsForApplication];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForApplicationWithCompletionHandlingBlock:

 @see \a +grantReadAccessRightsForApplicationAtPeriod:
 */
+ (void)auditAccessRightsForApplication;

/**
 Audit access rights for \a 'application' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForApplication: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [PubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForApplication:

 @see \a +grantReadAccessRightsForApplicationAtPeriod:
 */
+ (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree, which will also
 provide information about it's child levels: \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:withCompletionHandlingBlock:

 @see \a +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:' or '-auditAccessRightsFor:' instead. Class "
                           "method will be removed in future.");

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:

 @see \a +grantAllAccessRightsForChannel:forPeriod:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:withCompletionHandlingBlock:' or "
                           "'-auditAccessRightsFor:withCompletionHandlingBlock:' instead. Class method will be "
                           "removed in future.");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:client:withCompletionHandlingBlock:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:clients:' or '-auditAccessRightsFor:clients:' instead. Class "
                           "method will be removed in future.");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel:client: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:client:

 @see \a +grantAllAccessRightsForChannel:forPeriod:client:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:clients:withCompletionHandlingBlock:' or "
                           "'-auditAccessRightsFor:clients:withCompletionHandlingBlock:' instead. Class method will be "
                           "removed in future.");

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree,
 which will also provide information about it's child levels: \a 'user' level. This method allot to retrieve access
 rights information for set of \b PNChannel instances.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] to:PNWriteAccessRight 
                      onPeriod:10];
 [PubNub auditAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannels:withCompletionHandlingBlock:

 @see \a +grantWriteAccessRightsForChannels:forPeriod:
 */
+ (void)auditAccessRightsForChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:' or '-auditAccessRightsFor:' instead. Class method will be "
                           "removed in future.");

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree,
 which will also provide information about it's child levels: \a 'user' level. This method allot to retrieve access
 rights information for set of \b PNChannel instances.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] to:PNWriteAccessRight 
                      onPeriod:10];
 [PubNub auditAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsAuditDidCompleteNotification, kPNClientAccessRightsAuditDidFailNotification.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like 
                       \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub client should 
                       retrieve access rights information.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
+ (void)auditAccessRightsFor:(NSArray *)channelObjects;

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsFor: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [PubNub auditAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +grantWriteAccessRightsForChannels:forPeriod:
 */
+ (void)auditAccessRightsForChannels:(NSArray *)channels
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:withCompletionHandlingBlock:' or "
                           "'-auditAccessRightsFor:withCompletionHandlingBlock:' instead. Class method will be removed "
                           "in future.");

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsFor: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [PubNub auditAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like 
                       \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub client should 
                       retrieve access rights information.
 @param handlerBlock   The block which will be called by \b PubNub client when one of success or error events will be 
                       received. The block takes two arguments: \c collection - \b PNAccessRightsCollection instance 
                       which hold set of \b PNAccessRightsInformation instances to describe \a 'user' access rights for 
                       specific \c channel; \c error - error which describes what exactly went wrong during access 
                       rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes 
                       header file and use \a -localizedDescription / \a -localizedFailureReason and 
                       \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
+ (void) auditAccessRightsFor:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'user' level. This method allow to audit access rights to specific \a channel set of
 clients (authorization keys).

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:clients:withCompletionHandlingBlock:

 @see \a +grantReadAccessRightForChannel:forPeriod:clients:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:clients:' or '-auditAccessRightsFor:clients:' instead. Class "
                           "method will be removed in future.");

/**
 Audit access rights for \a 'user' level. This method allow to audit access rights to specific \a channel set of
 clients (authorization keys).

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsAuditDidCompleteNotification, kPNClientAccessRightsAuditDidFailNotification.

 @param object                   Object (which conforms to \b PNChannelProtocol data feed object protocol) like 
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub 
                                 client should retrieve access rights information.
 @param clientsAuthorizationKeys Array of \a NSString instances each of which represent client authorization key.

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
+ (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys;

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel:clients: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [PubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @see \b PNError class

 @see \b PNAccessRightOptions class

 @see \b PNChannel class

 @see \b PNAccessRightsCollection class

 @see \b PNAccessRightsInformation class

 @see \b PNObservationCenter class

 @see \a +auditAccessRightsForChannel:clients:

 @see \a +grantReadAccessRightForChannel:forPeriod:clients:
 */
+ (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '+auditAccessRightsFor:clients:withCompletionHandlingBlock:' or "
                           "'-auditAccessRightsFor:clients:withCompletionHandlingBlock:' instead. Class method "
                           "will be removed in future.");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a +auditAccessRightsForChannel:clients: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 [PubNub setConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
 [PubNub connect];
 [PubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [PubNub auditAccessRightsFor:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [[PNObservationCenter defaultCenter] addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param object                   Object (which conforms to \b PNChannelProtocol data feed object protocol) like 
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub 
                                 client should retrieve access rights information.
 @param clientsAuthorizationKeys Array of \a NSString instances each of which represent client authorization key.
 @param handlerBlock             The block which will be called by \b PubNub client when one of success or error events
                                 will be received. The block takes two arguments: \c collection - 
                                 \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation 
                                 instances to describe \a 'user' access rights for specific \c channel; \c error - error
                                 which describes what exactly went wrong during access rights audition. Always check 
                                 \a error.code to find out what caused error (check PNErrorCodes header file and use
                                 \a -localizedDescription / \a -localizedFailureReason and
                                 \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
+ (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @since 3.7.0
 */
- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:' with PNReadAccessRight to grant read "
                           "access right");

/**
 Grant \a 'read' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a -grantReadAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10
                         andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to any channels except \a 'iosdev'
 channel for which \a 'write' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'write' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'write'
 access rights and allow to post messages into target channel (for which \a 'write' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantReadAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read access right");

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @since 3.7.0
 */
- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:' with PNWriteAccessRight to grant write "
                           "access right");

/**
 Grant \a 'write' access right on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a -grantWriteAccessRightForApplicationAtPeriod: and allow to specify access rights change
 handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10
                          andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to any channels except \a 'iosdev'
 channel for which \a 'read' access rights has been granted for \b 10 minutes. But despite the fact that channel
 configured only for \a 'read' access rights, because of upper-layer configuration, \b PubNub client allowed to
 publish on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'application' access level.

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant \a 'read' access rights, then \b PubNub client will ignore the fact that top-layer forbid \a 'read'
 access rights and allow to to subscribe on target channel (for which \a 'read' access right has been granted).

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantWriteAccessRightForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                         andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write access right");

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightForApplicationAtPeriod:10];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @since 3.7.0
 */
- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:' with PNAllAccessRights to grant read and"
                           " write access rights");

/**
 Grant \a 'read'/ \a 'write' access rights on \a 'application' access level which will be valid for specified amount of time.

 @code
 @endcode
 This method extends \a -revokeAccessRightsForApplication: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightForApplicationAtPeriod:10
                        andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 [PubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes. But despite the fact that channel configured only for \a 'write' access rights, because of upper-layer configuration,
 \b PubNub client allowed to subscribe on \a 'iosdev' channel.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @warning \a 'application' access level is top-layer of access tree. If any of child access levels (\a 'channel' or
 \a 'user') grant only one of \a 'read' or \a 'write' access rights, \b PubNub client will ignore them and provide
 abilty to subscribe and post messages into any channels.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantAllAccessRightsForApplicationAtPeriod:(NSInteger)accessPeriodDuration
                        andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNAllAccessRights to grant read and write access rights");

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub revokeAccessRightsForApplication];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)revokeAccessRightsForApplication
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:' with PNNoAccessRights to revoke access "
                           "rights (duration will be ignored)");

/**
 Revoke all access rights on whole \a 'application' level.

 @code
 @endcode
 This method extends \a -revokeAccessRightsForApplication and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'application' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes (access rights has been
 granted exactly for this period of time).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from application level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }
 @endcode

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from application.
     }
     else {

         // PubNub client did fail to revoke access rights from application.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'application' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 
 @since 3.7.0
 */
- (void)revokeAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeApplicationAccessRightsTo:onPeriod:andCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored)");

/**
 @brief Alter application level access rights (based on subscription key).
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:10];
 [pubnub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes even despite the fact that channel configured only for \a 'write' access rights. It happens because application
 access rights has higher priority against channel based access rights.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, 
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.
 
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on application 
                             level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value
      (default value is \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter application level access rights (based on subscription key).
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:10
              andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 [pubnub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode

 Code above configure access rights in a way, which will allow to subscribe and post messages to any channel for \b 10
 minutes even despite the fact that channel configured only for \a 'write' access rights. It happens because application
 access rights has higher priority against channel based access rights.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'application' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from application level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, 
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'application' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from application level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.

 @param accessPeriodDuration
 Duration in minutes during which \a 'application' access level is granted with \a 'read'/ \a 'write' access rights.
 
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on application 
                             level.
 @param handlerBlock         The block which will be called by \b PubNub client when one of success or error events will 
                             be received. The block takes two arguments: \c collection - \b PNAccessRightsCollection 
                             instance which hold set of \b PNAccessRightsInformation instances to describe new 
                             \a 'application' access rights; \c error - error which describes what exactly went wrong
                             during access rights change. Always check \a error.code to find out what caused error 
                             (check PNErrorCodes header file and use \a -localizedDescription / 
                             \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable 
                             description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value
      (default value is \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
             andCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNReadAccessRight to grant read-only access"
                           " right.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a -grantReadAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'channel' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'channel' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only subscription, \b PubNub client allowed to post
 messages to any channels because of upper-layer configuration (\a 'application' access level allow message posting to any 
 channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read-only access right.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator"];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNReadAccessRight to "
                           "grant read-only access right.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time. 
 
 @code
 @endcode
 This method extends \a -grantReadAccessRightForChannel:forPeriod:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"spectator"
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for client with \a 'spectator' authorization key 
 into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only
 subscription for \a 'spectator', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientAuthorizationKey
 \a NSString instance which identify client which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNReadAccessRight to grant read-only access right.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNReadAccessRight to grant read-only "
                           "access right.");

/**
 Grant \a 'read' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a -grantReadAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [pubNub grantWriteAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only subscription, \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'application' access level allow message
 posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'write' access rights, 
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'write' access right and allow specific user (which has been granted 
 with \a 'write' access right) to post messages into target channel (for which \a 'write' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'read'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNReadAccessRight to grant read-only access right.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"spectator", @"visitor"]];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor' 
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNReadAccessRight to "
                           "grant read-only access right.");

/**
 Grant \a 'read' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a -grantReadAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                if (error == nil) {

                    // PubNub client successfully changed access rights for 'user' access level.
                }
                else {
 
                    // PubNub client did fail to revoke access rights from 'user' access level.
                    //
                    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                    // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                    // has been requested.
                }
 }];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'read' access right and revoke \a 'write' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'write' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'write' access rights and depending on who override 
 this value (\a 'application' or \a 'channel' access level) will allow message posting to all channels and for all 
 (in case if \a 'write' access rights granted on \a 'application' access level) or allow messsage posting for all into specific 
 channel (for channel which is granted with \a 'write' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'read' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'read' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantReadAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNReadAccessRight to grant read-only access right.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting,
 \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNWriteAccessRight to grant write-only "
                           "access right.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time.
 
 @code
 @endcode
 This method extends \a -grantWriteAccessRightForChannel:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'channel' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'channel' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev' channel for \b 10 minutes. 
 But despite the fact that \a 'iosdev' channel access rights allow only message posting, \b PubNub client allowed to post
 subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write-only access right.");
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNWriteAccessRight to "
                           "grant write-only access right.");
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                 client:(NSString *)clientAuthorizationKey
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNWriteAccessRight to grant write-only access right.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNWriteAccessRight to grant write-only "
                           "access right.");

/**
 Grant \a 'write' access right on \a 'channel' access level which will be valid for specified amount of time for specific set of channels.
 
 @code
 @endcode
 This method extends \a -grantWriteAccessRightForChannels:forPeriod: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]] forPeriod:10
              withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                  if (error == nil) {

                      // PubNub client successfully changed access rights for 'channel' access level.
                  }
                  else {
 
                      // PubNub client did fail to revoke access rights from 'channel' access level.
                      //
                      // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                      // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                      // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                      // has been requested.
                  }
 }];
 [pubNub grantReadAccessRightForApplicationAtPeriod:10];
 @endcode

 Code above configure access rights in a way, which won't allow subscription to \a 'iosdev', \a 'androiddev' and \a 'macosdev' channels
 for \b 10 minutes. But despite the fact that\a 'iosdev', \a 'androiddev' and \a 'macosdev' channels access rights
 allow only message posting, \b PubNub client allowed to post subscribe to any channels because of upper-layer configuration (\a 'application' access level allow subscription
 to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'channel' access level.

 @warning \a 'channel' access level is mid-layer of access tree. If \a 'user' access level grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that mid-layer forbid \a 'read' access right and allow specific user (which has been granted
 with \a 'read' access right) to subscribe on target channel (for which \a 'read' access right has been granted).
 
 @param channels
 List of \b PNChannel instances for which \b PubNub client should change access rights to \a 'write'.

 @param accessPeriodDuration
 Duration in minutes during which \a 'channel' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
             withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNWriteAccessRight to grant write-only access right.");

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow subscription on \a 'iosdev' channel for clients with \a 'spectator' and \a 'visitor'
 authorization keys for \b 10 minutes. But despite the fact that \a 'iosdev' channel access rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNWriteAccessRight to "
                           "grant write-only access right.");

/**
 Grant \a 'write' access right on \a 'user' access level which will be valid for specified amount of time for specific set of cliens authorization keys.
 
 @code
 @endcode
 This method extends \a -grantWriteAccessRightForChannel:forPeriod:clients: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@[@"spectator", @"visitor"]
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

                 if (error == nil) {

                     // PubNub client successfully changed access rights for 'user' access level.
                 }
                 else {
 
                     // PubNub client did fail to revoke access rights from 'user' access level.
                     //
                     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
                     // has been requested.
                 }
 }];
 [pubNub grantWriteAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which won't allow message posting for clients with \a 'spectator' and \a 'visitor'
 authorization keys into \a 'iosdev' channel for \b 10 minutes. But despite the fact that \a 'iosdev' channel access
 rights allow only subscription for \a 'spectator' and \a 'visitor', \b PubNub client allowed to post messages to any channels because of upper-layer
 configuration (\a 'channel' access level allow message posting to any channels for \b 10 minutes).

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'user' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'user' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
     // has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'user' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'user' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which change
         // has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is \b 1440 minutes).

 @note When this API is used, it will grant \a 'write' access right and revoke \a 'read' access right for
 \a 'user' access level.

 @warning \a 'user' access level is low-layer of access tree. If one of upper layers will grant \a 'read' access rights,
 then \b PubNub client will ignore the fact that low-layer forbid \a 'read' access rights and depending on who override
 this value (\a 'application' or \a 'channel' access level) will allow subscription to all channels and for all
 (in case if \a 'read' access rights granted on \a 'application' access level) or allow subscription for all on specific
 channel (for channel which is granted with \a 'read' access rights).
 
 @param channel
 \b PNChannel instance for which \b PubNub client should change access rights for specific client.
 
 @param clientsAuthorizationKeys
 Set of \a NSString instances which identify clients which should be granted with \a 'write' access right on specific \c channel.

 @param accessPeriodDuration
 Duration in minutes during which \a 'user' access level is granted with \a 'write' access rights.
 
 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'user' access rights; \c error - error which describes what exactly went wrong
 during access rights change. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @since 3.7.0
 */
- (void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                clients:(NSArray *)clientsAuthorizationKeys
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNWriteAccessRight to grant write-only access right.");

- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNAllAccessRights to grant and write access"
                           " rights.");
- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNAllAccessRights to grant and write access rights.");
- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNAllAccessRights to "
                           "grant and write access rights.");
- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                                client:(NSString *)clientAuthorizationKey
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNAllAccessRights to grant and write access rights.");
- (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNAllAccessRights to grant and write access"
                           " rights.");
- (void)grantAllAccessRightsForChannels:(NSArray *)channels forPeriod:(NSInteger)accessPeriodDuration
            withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNAllAccessRights to grant and write access rights.");
- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNAllAccessRights to "
                           "grant and write access rights.");
- (void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSInteger)accessPeriodDuration
                               clients:(NSArray *)clientsAuthorizationKeys
           withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNAllAccessRights to grant and write access rights.");

- (void)revokeAccessRightsForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNNoAccessRights to revoke access rights "
                           "(duration will be ignored).");

/**
 Revoke all access rights on whole \a 'channel' level.

 @code
 @endcode
 This method extends \a +revokeAccessRightsForChannel: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [pubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)revokeAccessRightsForChannel:(PNChannel *)channel
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored).");

- (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNNoAccessRights to "
                           "revoke access rights (duration will be ignored).");

/**
 Revoke all access rights on \a 'user' level. Access rights will be revoked for specific user on specific channel.

 @code
 @endcode
 This method extends \a -revokeAccessRightsForChannel:client: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [pubNub revokeAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights for user at channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights for user at channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights for user at channel level.
     }
     else {

         // PubNub client did fail to revoke access rights for user at channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client should revoke all access rights on specific user \c clientAuthorizationKey.

 @param clientAuthorizationKey
 \a NSString instance which holds client authorization key from which access rights should be revoked.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 
 @since 3.7.0
 */
- (void)revokeAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNNoAccessRights to revoke access rights (duration will be ignored).");
- (void)revokeAccessRightsForChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:' with PNNoAccessRights to revoke access rights "
                           "(duration will be ignored).");

/**
 Revoke all access rights on whole \a 'channel' level. This method allow to revoke access rights for the set of \b
 PNChannel instances.

 @code
 @endcode
 This method extends \a -revokeAccessRightsForChannels: and allow to specify access rights change handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client", @"admin"]];
 [pubNub revokeAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]]
           withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];
 @endcode

 Despite the fact that all access rights has been revoked on \a 'channel' level in code above,
 \b PubNub client will be able to subscribe and post into \a "iosdev" channel for \b 10 minutes from the client which
 use \a "admin" authorization key.

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully revoked all access rights from channel level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from channel level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
 }

 There is also way to observe revoke process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully revoked all access rights from channel level.
     }
     else {

         // PubNub client did fail to revoke access rights from channel level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which revoke has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsChangeDidCompleteNotification,
 kPNClientAccessRightsChangeDidFailNotification.

 @param channels
 List of \b PNChannel instances from which \b PubNub client should revoke all access rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe new \a 'channel' access rights; \c error - error which describes what exactly went wrong
 during access rights revoke. Always check \a error.code to find out what caused error (check PNErrorCodes header file
 and use \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)revokeAccessRightsForChannels:(NSArray *)channels
          withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsFor:to:onPeriod:withCompletionHandlingBlock:' with "
                           "PNNoAccessRights to revoke access rights (duration will be ignored).");
- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:' with PNNoAccessRights to "
                           "revoke access rights (duration will be ignored).");
- (void)revokeAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-changeAccessRightsForClients:object:to:onPeriod:withCompletionHandlingBlock:' "
                           "with PNNoAccessRights to revoke access rights (duration will be ignored).");

/**
 @brief Alter channel(s) level access rights.
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]]
                            to:PNReadAccessRight onPeriod:10];
 [pubNub changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:10];
 @endcode
 
 
 Code above configure access rights in a way, which will allow to subscribe and post messages to \a 'iosdev', 
 \a 'androiddev' and \a 'macosdev' channels for \b 10 minutes even despite the fact that channels configured only for
 \a 'read' access rights. It happens because application access rights has higher priority against channel based access
 rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection,
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param channelObjects       List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                             \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which access rights
                             should be changed
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on channel level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter channel(s) level access rights.
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"androiddev", @"macosdev"]]
                            to:PNReadAccessRight onPeriod:10
   withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 [pubNub changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:10];
 @endcode
 
 Code above configure access rights in a way, which will allow to subscribe and post messages to \a 'iosdev', 
 \a 'androiddev' and \a 'macosdev' channels for \b 10 minutes even despite the fact that channels configured only for
 \a 'read' access rights. It happens because application access rights has higher priority against channel based access
 rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection,
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param channelObjects       List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                             \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which access rights 
                             should be changed
 @param accessRights         Bit field which allow to specify set of options. Bit options specified in \c PNAccessRights
 @param accessPeriodDuration Duration in minutes during which provided access rights should be applied on channel level.
 @param handlerBlock         The block which will be called by \b PubNub client when one of success or error events will 
                             be received. The block takes two arguments: \c collection - \b PNAccessRightsCollection 
                             instance which hold set of \b PNAccessRightsInformation instances to describe new 
                             \a 'channel' access rights; \c error - error which describes what exactly went wrong during
                             access rights change. Always check \a error.code to find out what caused error (check 
                             PNErrorCodes header file and use \a -localizedDescription / \a -localizedFailureReason and
                             \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeAccessRightsFor:(NSArray *)channelObjects to:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration
  withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 @brief Alter channel(s) level access rights.
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsForClients:@[@"spectator", @"visitor"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [pubNub changeAccessRightsFor:[PNChannel channelsWithNames:@"iosdev"] to:PNWriteAccessRight onPeriod:10];
 @endcode
 
 Code above allow to subscribe and post messages to \a 'iosdev' channel even for \a 'spectator' and \a 'visitor' users.
 It happens because channel access rights has higher priority against user based access rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection,
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param clientsAuthorizationKeys List of \a NSString instances which specify list of client for which access rights 
                                 should be changed.
 @param object                   List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on channel 
                                 level.
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration;

/**
 @brief Alter channel(s) level access rights.
 
 @code
 @endcode
 \b Example:

 @code
 PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                             subscribeKey:@"demo" secretKey:@"my-secret-key"];
 PubNub *pubNub = [PubNub clientWithConfiguration:configuration andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsForClients:@[@"spectator", @"visitor"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

      if (error == nil) {

          // PubNub client successfully changed access rights for 'user' access level.
      }
      else {

          // PubNub client did fail to revoke access rights from 'user' access level.
          //
          // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
          // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human  readable 
          // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
          // access level for which change has been requested.
      }
 }];
 [pubNub changeAccessRightsFor:@[[PNChannel channelWithName:@"iosdev"]] to:PNWriteAccessRight onPeriod:10];
 @endcode
 
 Code above allow to subscribe and post messages to \a 'iosdev' channel even for \a 'spectator' and \a 'visitor' users.
 It happens because channel access rights has higher priority against user based access rights.
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully changed access rights for 'channel' access level.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {

     // PubNub client did fail to revoke access rights from 'channel' access level.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which change has been requested.
 }
 @endcode

 There is also way to observe access rights change process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsChangeObserver:self withBlock:^(PNAccessRightsCollection *collection,
                                                                          PNError *error) {

     if (error == nil) {

         // PubNub client successfully changed access rights for 'channel' access level.
     }
     else {

         // PubNub client did fail to revoke access rights from 'channel' access level.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which change has been requested.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsChangeDidCompleteNotification, kPNClientAccessRightsChangeDidFailNotification.
 
 @param clientsAuthorizationKeys List of \a NSString instances which specify list of client for which access rights 
                                 should be changed.
 @param object                   List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace
 @param accessRights             Bit field which allow to specify set of options. Bit options specified in 
                                 \c PNAccessRights
 @param accessPeriodDuration     Duration in minutes during which provided access rights should be applied on channel 
                                 level.
 @param handlerBlock             The block which will be called by \b PubNub client when one of success or error events
                                 will be received. The block takes two arguments: \c collection -
                                 \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation 
                                 instances to describe new \a 'user' access rights; \c error - error which describes 
                                 what exactly went wrong during access rights change. Always check \a error.code to find
                                 out what caused error (check PNErrorCodes header file and use 
                                 \a -localizedDescription / \a -localizedFailureReason and 
                                 \a -localizedRecoverySuggestion to get human readable description for error).
 
 @note To be able use this API, you should provide \a 'secret' key which is used for signature generation.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @note You can pass a value less than \c 0 as \a 'accessPeriodDuration' argument to use default value (default value is 
       \b 1440 minutes).
 
 @since 3.7.0
 */
- (void)changeAccessRightsForClients:(NSArray *)clientsAuthorizationKeys object:(id <PNChannelProtocol>)object
                                  to:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration
         withCompletionHandlingBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

/**
 Audit access rights for \a 'application' level. \a 'application' level is top-layer of access rights tree which will
 also provide information about it's child levels: \a 'channel' and \a 'user' levels.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [pubNub auditAccessRightsForApplication];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForApplication;

/**
 Audit access rights for \a 'application' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsForApplication: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightsForApplicationAtPeriod:10];
 [pubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForApplicationWithCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree, which will also
 provide information about it's child levels: \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:' instead");

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsForChannel: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in
 response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:withCompletionHandlingBlock:' instead");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:clients:' instead");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsForChannel:client: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantAllAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 client:@"admin"];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] client:@"admin"
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specific client authorization key.

 @param clientAuthorizationKey
 \a NSString instances of client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or \c clientAuthorizationKey
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:clients:withCompletionHandlingBlock:' instead");

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree,
 which will also provide information about it's child levels: \a 'user' level. This method allot to retrieve access
 rights information for set of \b PNChannel instances.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [pubNub auditAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannels:(NSArray *)channels
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:' instead.");

/**
 Audit access rights for \a 'channel' level. \a 'channel' level is mid-layer of access rights tree,
 which will also provide information about it's child levels: \a 'user' level. This method allot to retrieve access
 rights information for set of \b PNChannel instances.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] to:PNWriteAccessRight
                      onPeriod:10];
 [pubNub auditAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
     // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
     // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes access 
     // level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use 
         // -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion to get human readable 
         // description for error). 'error.associatedObject' contains PNAccessRightOptions instance which describes 
         // access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsAuditDidCompleteNotification, kPNClientAccessRightsAuditDidFailNotification.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like 
                       \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub client should 
                       retrieve access rights information.

 @note Event if you never configured access rights for \c channel it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
- (void)auditAccessRightsFor:(NSArray *)channelObjects;

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsForChannels: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [pubNub auditAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channels
 List of \b PNChannel instances for which \b PubNub client should retrieve access rights information.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannels:(NSArray *)channels
         withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:withCompletionHandlingBlock:' instead.");

/**
 Audit access rights for \a 'channel' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsFor: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantWriteAccessRightsForChannels:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev"]] forPeriod:10];
 [pubNub auditAccessRightsFor:[PNChannel channelsWithNames:@[@"iosdev", @"macosdev", @"androiddev"]]
          withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channelObjects List of objects (which conforms to \b PNChannelProtocol data feed object protocol) like 
                       \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub client should 
                       retrieve access rights information.
 @param handlerBlock   The block which will be called by \b PubNub client when one of success or error events will be 
                       received. The block takes two arguments: \c collection - \b PNAccessRightsCollection instance 
                       which hold set of \b PNAccessRightsInformation instances to describe \a 'user' access rights for 
                       specific \c channel; \c error - error which describes what exactly went wrong during access 
                       rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes 
                       header file and use \a -localizedDescription / \a -localizedFailureReason and 
                       \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
- (void) auditAccessRightsFor:(NSArray *)channelObjects
  withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

/**
 Audit access rights for \a 'user' level. This method allow to audit access rights to specific \a channel set of
 clients (authorization keys).

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client1", @"client2", @"admin"]];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:clients:' instead.");

/**
 Audit access rights for \a 'user' level. This method allow to audit access rights to specific \a channel set of
 clients (authorization keys).

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [pubNub auditAccessRightsFor:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientAccessRightsAuditDidCompleteNotification, kPNClientAccessRightsAuditDidFailNotification.

 @param object                   Object (which conforms to \b PNChannelProtocol data feed object protocol) like 
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub 
                                 client should retrieve access rights information.
 @param clientsAuthorizationKeys Array of \a NSString instances each of which represent client authorization key.

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
- (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys;

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsForChannel:clients: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub grantReadAccessRightForChannel:[PNChannel channelWithName:@"iosdev"] forPeriod:10 clients:@[@"client1", @"client2", @"admin"]];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param channel
 \b PNChannel instance for which \b PubNub client check rights for specified set of clients (authorization keys).

 @param clientsAuthorizationKeys
 Array of \a NSString instances each of which represent client authorization key.

 @param handlerBlock
 The block which will be called by \b PubNub client when one of success or error events will be received. The block
 takes two arguments:
 \c collection - \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation instances to
 describe \a 'user' access rights for specific \c channel; \c error - error which describes what exactly went wrong
 during access rights audition. Always check \a error.code to find out what caused error (check PNErrorCodes header file and use
 \a -localizedDescription / \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.

 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.

 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.

 @since 3.7.0
 */
- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock
  DEPRECATED_MSG_ATTRIBUTE(" Use '-auditAccessRightsFor:clients:withCompletionHandlingBlock:' instead.");

/**
 Audit access rights for \a 'user' level.

 @code
 @endcode
 This method extends \a -auditAccessRightsFor:clients: and allow to specify audition process handler block.

 @code
 @endcode
 \b Example:

 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo"
                                                           subscribeKey:@"demo" secretKey:@"my-secret-key"]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub changeAccessRightsForClients:@[@"client1", @"client2", @"admin"] object:[PNChannel channelWithName:@"iosdev"]
                                   to:PNReadAccessRight onPeriod:10];
 [pubNub auditAccessRightsForChannel:[PNChannel channelWithName:@"iosdev"] clients:@[@"client1", @"client2", @"admin", @"spectator]
         withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];
 @endcode

 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {

     // PubNub client successfully pulled out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
 }

 - (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {

     // PubNub client did fail to pull out access rights information for specified object (object defined by set
     // of parameters used for \a 'audit' request.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
     // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
     // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
 }
 @endcode

 There is also way to observe audition process from any place in your application using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *collection, PNError *error) {

     if (error == nil) {

         // PubNub client successfully pulled out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
     }
     else {

         // PubNub client did fail to pull out access rights information for specified object (object defined by set
         // of parameters used for \a 'audit' request.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
         // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' contains PNAccessRightOptions instance which describes access level for which audition has been requested.
     }
 }];

 Also observation can be done using \b NSNotificationCenter to observe this notifications: kPNClientAccessRightsAuditDidCompleteNotification,
 kPNClientAccessRightsAuditDidFailNotification.

 @param object                   Object (which conforms to \b PNChannelProtocol data feed object protocol) like 
                                 \b PNChannel, \b PNChannelGroup or \b PNChannelGroupNamespace for which \b PubNub 
                                 client should retrieve access rights information.
 @param clientsAuthorizationKeys Array of \a NSString instances each of which represent client authorization key.
 @param handlerBlock             The block which will be called by \b PubNub client when one of success or error events
                                 will be received. The block takes two arguments: \c collection - 
                                 \b PNAccessRightsCollection instance which hold set of \b PNAccessRightsInformation 
                                 instances to describe \a 'user' access rights for specific \c channel; \c error - error
                                 which describes what exactly went wrong during access rights audition. Always check 
                                 \a error.code to find out what caused error (check PNErrorCodes header file and use
                                 \a -localizedDescription / \a -localizedFailureReason and
                                 \a -localizedRecoverySuggestion to get human readable description for error).

 @note Event if you never configured access rights for \c channel or one of clients from \c clientsAuthorizationKeys
 it's value will be calculated and returned in response.
 @note Make sure that you enabled "Access Manager" on https://admin.pubnub.com.
 @warning As soon as "Access Manager" will be enabled, all \b PubNub clients won't be able to subscribe / publish to
 any channels till the moment, when access rights will be configured.
 */
- (void)auditAccessRightsFor:(id <PNChannelProtocol>)object clients:(NSArray *)clientsAuthorizationKeys
        withCompletionHandlingBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;

#pragma mark -


@end
