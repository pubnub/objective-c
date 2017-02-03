/**
 @brief  Define list of macro which used by clien't component to print out messages using 
         \b PNLLogger.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNLLogger.h"

#pragma once

#define PNLOG(logger, level, frmt, ...) [logger log:level format:frmt, ##__VA_ARGS__]
#define DDLogClientInfo(logger, frmt, ...) PNLOG(logger, PNInfoLogLevel, frmt, ##__VA_ARGS__)
#define DDLogReachability(logger, frmt, ...) PNLOG(logger, PNReachabilityLogLevel, frmt, ##__VA_ARGS__)
#define DDLogRequest(logger, frmt, ...) PNLOG(logger, PNRequestLogLevel, frmt, ##__VA_ARGS__)
#if defined(__MAC_10_12) || defined(__IPHONE_10_0) || defined(__WATCHOS_3_0) || defined(__TVOS_10_0)
    #define DDLogRequestMetrics(logger, frmt, ...) PNLOG(logger, PNRequestMetricsLogLevel, frmt, ##__VA_ARGS__)
#endif
#define DDLogResult(logger, frmt, ...) PNLOG(logger, PNResultLogLevel, frmt, ##__VA_ARGS__)
#define DDLogStatus(logger, frmt, ...) PNLOG(logger, PNStatusLogLevel, frmt, ##__VA_ARGS__)
#define DDLogFailureStatus(logger, frmt, ...) PNLOG(logger, PNFailureStatusLogLevel, frmt, ##__VA_ARGS__)
#define DDLogAESError(logger, frmt, ...) PNLOG(logger, PNAESErrorLogLevel, frmt, ##__VA_ARGS__)
#define DDLogAPICall(logger, frmt, ...) PNLOG(logger, PNAPICallLogLevel, frmt, ##__VA_ARGS__)
