//
//  PNDate.h
//  pubnub
//
//  Created by Sergey Mamontov on 04/01/13.
//
//

#import <Foundation/Foundation.h>


@interface PNDate : NSObject


#pragma mark Properties

// Stores reference on raw time token value
@property (nonatomic, readonly, strong) NSNumber *timeToken;

// Stores reference on date generated from time token
@property (nonatomic, readonly, strong) NSDate *date;


#pragma mark - Class methods

/**
 * Retrieve reference on fully configured date object which can be
 * used in request to repote origin
 */
+ (instancetype)dateWithDate:(NSDate *)date;
+ (instancetype)dateWithToken:(NSNumber *)number;

#pragma mark -


@end
