/**
 @brief  Define list of macro which used by clien't component to print out messages using 
         \b CocoaLumberjack framework.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <CocoaLumberjack/CocoaLumberjack.h>

#pragma once


#define PNLOG(level, pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)level, 0, nil, \
                                           __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
//#define DDLogClientInfo(pnll, frmt, ...) PNLOG(NO, pnll, (DDLogFlag)PNInfoLogLevel, 0, nil, \
                                         __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogClientInfo(pnll, frmt, ...) PNLOG(PNInfoLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogReachability(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNReachabilityLogLevel, 0, \
                                           nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogReachability(pnll, frmt, ...) PNLOG(PNReachabilityLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogRequest(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNRequestLogLevel, 0, nil, \
                                      __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogRequest(pnll, frmt, ...) PNLOG(PNRequestLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogResult(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNResultLogLevel, 0, nil, \
                                     __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogResult(pnll, frmt, ...) PNLOG(PNResultLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogStatus(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNStatusLogLevel, 0, nil, \
                                     __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogStatus(pnll, frmt, ...) PNLOG(PNStatusLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogFailureStatus(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNFailureStatusLogLevel, \
                                            0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogFailureStatus(pnll, frmt, ...) PNLOG(PNFailureStatusLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogAESError(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNAESErrorLogLevel, 0, nil, \
                                       __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAESError(pnll, frmt, ...) PNLOG(PNAESErrorLogLevel, pnll, frmt, ##__VA_ARGS__)
//#define DDLogAPICall(pnll, frmt, ...) LOG_MAYBE(NO, pnll, (DDLogFlag)PNAPICallLogLevel, 0, nil, \
                                      __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAPICall(pnll, frmt, ...) PNLOG(PNAPICallLogLevel, pnll, frmt, ##__VA_ARGS__)
