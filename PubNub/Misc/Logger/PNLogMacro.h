/**
 @brief  Define list of macro which used by clien't component to print out messages using 
         \b PNLLogger.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNLLogger.h"
#import "PNDefines.h"

#pragma once

#define PNLOG(logger, level, frmt, ...) [logger log:level format:frmt, ##__VA_ARGS__]
#define PNLogClientInfo(logger, frmt, ...) PNLOG(logger, PNInfoLogLevel, frmt, ##__VA_ARGS__)
#define PNLogReachability(logger, frmt, ...) PNLOG(logger, PNReachabilityLogLevel, frmt, ##__VA_ARGS__)
#define PNLogRequest(logger, frmt, ...) PNLOG(logger, PNRequestLogLevel, frmt, ##__VA_ARGS__)
#if PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE
    #define PNLogRequestMetrics(logger, frmt, ...) PNLOG(logger, PNRequestMetricsLogLevel, frmt, ##__VA_ARGS__)
#endif
#define PNLogResult(logger, frmt, ...) PNLOG(logger, PNResultLogLevel, frmt, ##__VA_ARGS__)
#define PNLogStatus(logger, frmt, ...) PNLOG(logger, PNStatusLogLevel, frmt, ##__VA_ARGS__)
#define PNLogFailureStatus(logger, frmt, ...) PNLOG(logger, PNFailureStatusLogLevel, frmt, ##__VA_ARGS__)
#define PNLogAESError(logger, frmt, ...) PNLOG(logger, PNAESErrorLogLevel, frmt, ##__VA_ARGS__)
#define PNLogAPICall(logger, frmt, ...) PNLOG(logger, PNAPICallLogLevel, frmt, ##__VA_ARGS__)
