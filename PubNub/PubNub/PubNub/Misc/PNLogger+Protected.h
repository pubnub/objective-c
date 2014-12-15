//
//  PNLogger_Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 8/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNLogger.h"


#pragma mark - Exuension declaration

@interface PNLogger (Protected)


#pragma mark - Class methods

/**
 Complete logger initialization process.
 */
+ (void)prepare;

/**
 Log out message for specified level using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logFrom:(id)sender forLevel:(PNLogLevel)level withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'general' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logGeneralMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'reachability' level log message using data returned from \c messageBlock block.
 K
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logReachabilityMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'deserializer info' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logDeserializerInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'deserializer error' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logDeserializerErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'connection HTTP packet' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param parametersBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logConnectionHTTPPacketFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'connection info' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logConnectionInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'connection error' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logConnectionErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'communication channel error' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelErrorMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'communication channel warn' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelWarnMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Log out \c 'communication channel info' level log message using data returned from \c messageBlock block.
 
 @param sender
 Reference on instance from the name of which message will be logged.
 
 @param messageBlock
 Block which is used by logger to receive message which should be processed and shown in Xcode console and device logs.
 */
+ (void)logCommunicationChannelInfoMessageFrom:(id)sender withParametersFromBlock:(NSArray *(^)(void))parametersBlock;

/**
 Store data passed through \c httpPacketBlock block into separate file which will represent single HTTP packet.
 
 @param httpPacketBlock
 Block which is used by logger to receive \b NSData instance which contains all payload which has been received from server.
 */
+ (void)storeHTTPPacketData:(NSData *(^)(void))httpPacketBlock;

/**
 Store data passed through \c httpPacketBlock block into separate file which will represent unexpected HTTP packet.
 
 @param httpPacketBlock
 Block which is used by logger to receive \b NSData instance which contains all payload which has been received from server.
 */
+ (void)storeUnexpectedHTTPDescription:(NSString *)packetDescription packetData:(NSData *(^)(void))httpPacketBlock;

#pragma mark -


@end
