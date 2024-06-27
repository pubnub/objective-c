/// Define list of macro which used by clien't component to print out messages using ``PNLLogger``.

#pragma once

#ifndef PUBNUB_DISABLE_LOGGER
#import "PNLLogger.h"
#import "PNDefines.h"

#define PNLOG(logger, level, frmt, ...) [logger log:level format:frmt, ##__VA_ARGS__]
#define PNLogClientInfo(logger, frmt, ...) PNLOG(logger, PNInfoLogLevel, frmt, ##__VA_ARGS__)
#define PNLogReachability(logger, frmt, ...) PNLOG(logger, PNReachabilityLogLevel, frmt, ##__VA_ARGS__)
#define PNLogRequest(logger, frmt, ...) PNLOG(logger, PNRequestLogLevel, frmt, ##__VA_ARGS__)
#define PNLogResult(logger, frmt, ...) PNLOG(logger, PNResultLogLevel, frmt, ##__VA_ARGS__)
#define PNLogStatus(logger, frmt, ...) PNLOG(logger, PNStatusLogLevel, frmt, ##__VA_ARGS__)
#define PNLogFailureStatus(logger, frmt, ...) PNLOG(logger, PNFailureStatusLogLevel, frmt, ##__VA_ARGS__)
#define PNLogAESError(logger, frmt, ...) PNLOG(logger, PNAESErrorLogLevel, frmt, ##__VA_ARGS__)
#define PNLogAPICall(logger, frmt, ...) PNLOG(logger, PNAPICallLogLevel, frmt, ##__VA_ARGS__)
#else
#define PNLOG(logger, level, frmt, ...)
#define PNLogClientInfo(logger, frmt, ...)
#define PNLogReachability(logger, frmt, ...)
#define PNLogRequest(logger, frmt, ...)
#define PNLogResult(logger, frmt, ...)
#define PNLogStatus(logger, frmt, ...)
#define PNLogFailureStatus(logger, frmt, ...)
#define PNLogAESError(logger, frmt, ...)
#define PNLogAPICall(logger, frmt, ...)
#endif // PUBNUB_DISABLE_LOGGER
