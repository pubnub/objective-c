/**
 @author Sergey Mamontov
 @since 4.2
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNNumber.h"


#pragma mark Static

/**
 @brief  Stores how many digits is expected from number to be accepted by \b PubNub service.
 */
static NSUInteger const kPNRequiredTimeTokenPrecision = 17;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNNumber ()


#pragma mark - Misc

/**
 @brief      Convert number to required type (taking into account type).
 @discussion If number has been created from float or double, value will be adjusted to shift 
             floating point away.
 
 @return Normalized number instance.
 
 @since 4.2.0
 */
+ (NSNumber *)normalizeValue:(NSNumber *)number;

/**
 @brief  Retrieve passed object precision information.
 
 @param number Reference on number for which precision should be calculated.
 
 @return Passed number precision.
 
 @since 4.2.0
 */
+ (NSUInteger)numberPrecision:(NSNumber *)number;

/**
 @brief  Calculate required multiplier to adjust passed number precision to required one.
 
 @param precision Passed value precision.
 
 @return Multiplier on which original value should be multiplied during timetoken initialization.
 
 @since 4.2.0
 */
+ (NSUInteger)correctionForPrecision:(NSUInteger)precision;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNNumber


#pragma mark - Conversion

+ (NSNumber *)timeTokenFromNumber:(NSNumber *)number {
    
    NSNumber *timeToken = nil;
    if (number) {
        
        NSNumber *value = [self normalizeValue:number];
        timeToken = @(value.unsignedLongLongValue * [self correctionForPrecision:[self numberPrecision:value]]);
    }
    
    return timeToken;
}


#pragma mark - Misc

+ (NSNumber *)normalizeValue:(NSNumber *)number {
    
    NSNumber *normalizeValue = number;
    if (strcmp(number.objCType, @encode(float)) == 0 ||
        strcmp(number.objCType, @encode(double)) == 0) {
        
        double doubleValue = number.doubleValue;
        unsigned long long unsignedLongLongValue = number.unsignedLongLongValue;
        normalizeValue = @((doubleValue - unsignedLongLongValue > 0) ? doubleValue * 1000000 : doubleValue);
    }
    
    return normalizeValue;
}

+ (NSUInteger)numberPrecision:(NSNumber *)number {
    
    return ([number unsignedLongLongValue] > 0 ?
            ((NSUInteger)floor(log10(number.unsignedLongLongValue)) + 1) : 0);
}

+ (NSUInteger)correctionForPrecision:(NSUInteger)precision {
    
    NSUInteger precisionDiff = (precision > 0 ? (kPNRequiredTimeTokenPrecision - precision) : 0);
    NSUInteger correctionMultiplier = 1;
    while (precisionDiff != 0) {
        
        correctionMultiplier *= 10;
        precisionDiff--;
    }
    
    return correctionMultiplier;
}

#pragma mark -


@end
