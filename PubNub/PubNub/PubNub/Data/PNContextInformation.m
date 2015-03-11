/**
 @author Sergey Mamontov
 @since 3.7.9.2
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNContextInformation.h"


#pragma mark Private interface declaration

@interface PNContextInformation ()


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) id object;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNContextInformation


#pragma mark - Class methods

+ (instancetype)contextWithObject:(id)object {
    
    PNContextInformation *information = [self new];
    information.object = object;
    
    
    return information;
}

#pragma mark -


@end
