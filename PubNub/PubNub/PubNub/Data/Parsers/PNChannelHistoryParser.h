//
//  PNChannelHistoryParser.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import <Foundation/Foundation.h>
#import "PNResponseParser.h"


#pragma mark Public interface declaration

@interface PNChannelHistoryParser : PNResponseParser


#pragma mark - Class methods

/**
 Verify whether provided response has information about storage error or not.
 
 @param response
 \b PNResponse instance against which check should be performed.
 
 @return \c YES if response contains information about storage error.
 */
+ (BOOL)isErrorResponse:(PNResponse *)response;

/**
 Extract error message from response.
 
 @param response
 \b PNResponse instance from which message should be extracted.
 
 @return \b NSString instance which will describe error.
 */
+ (NSString *)errorMessage:(PNResponse *)response;

#pragma mark -


@end
