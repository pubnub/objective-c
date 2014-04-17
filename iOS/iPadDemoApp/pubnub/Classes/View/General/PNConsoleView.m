//
//  PNConsoleView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNConsoleView.h"


#pragma mark Private interface declaration

@interface PNConsoleView ()


#pragma mark - Properties

/**
 Stores reference on attributed string which will store all previous messages.
 */
@property (nonatomic, strong) NSMutableAttributedString *stringForLayout;


#pragma mark - Instance methods

/**
 Convert required pieces of original string using required formatting styles into attributed string.
 
 @param string
 Original string which should be formatted.
 
 @return Formatted string which will be shown in console.
 */
- (NSAttributedString *)attributedStringFrom:(NSString *)string;

/**
 Method which will modify attributes inside provided string for all presence events.
 
 @param attributedString
 \b NSMutableAttributedString instance which should be modified to apply formatting for presence events.
 */
- (void)formatPresenceEventsIn:(NSMutableAttributedString *)attributedString;

/**
 Method which will modify attributes inside provided string for all date tokens.
 
 @param attributedString
 \b NSMutableAttributedString instance which should be modified to apply formatting for date tokens.
 */
- (void)formatDatesIn:(NSMutableAttributedString *)attributedString;


#pragma mark - Misc methods

/**
 Try to identify presence event in console output.
 
 @param searchRange
 Range which specify limits for search.
 
 @param string
 String across which search should be performed.
 
 @return \b NSRange value for next presence event which should be formatted.
 */
- (NSRange)presenceEventRangeInRange:(NSRange)searchRange forString:(NSString *)string;

/**
 Compute target color for presence event message.
 
 @param searchRange
 Range which specify limits for search.
 
 @param string
 String across which search should be performed.
 
 @return Depending on event type (joined, leaved or timeout) corresponding color will be returned.
 */
- (UIColor *)colorForPresenceEventInRange:(NSRange)searchRange forString:(NSString *)string;

/**
 Try to identify date token in console output.
 
 @param searchRange
 Range which specify limits for search.
 
 @param string
 String across which search should be performed.
 
 @return \b NSRange value for next date token which should be formatted.
 */
- (NSRange)dateRangeInRange:(NSRange)searchRange forString:(NSString *)string;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNConsoleView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    self.stringForLayout = [NSMutableAttributedString new];
}

- (void)setOutputTo:(NSString *)consoleOutput {
    
    self.stringForLayout = [NSMutableAttributedString new];
    
    if ([consoleOutput length]) {
        
        [self.stringForLayout appendAttributedString:[self attributedStringFrom:consoleOutput]];
    }
    self.attributedText = self.stringForLayout;
}

- (void)addOutput:(NSString *)consoleOutput {
    
    if ([consoleOutput length]) {
        
        [self.stringForLayout appendAttributedString:[self attributedStringFrom:consoleOutput]];
    }
    self.attributedText = self.stringForLayout;
}

- (NSAttributedString *)attributedStringFrom:(NSString *)string {
    
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                         attributes:@{NSFontAttributeName:defaultFont}];
    [self formatPresenceEventsIn:attributedString];
    [self formatDatesIn:attributedString];
    
    
    return attributedString;
}

- (void)formatPresenceEventsIn:(NSMutableAttributedString *)attributedString {
    
    NSInteger searchLength = [attributedString.string length];
    NSRange searchRange = NSMakeRange(0, searchLength);
    NSRange presenceEventRange = [self presenceEventRangeInRange:searchRange forString:attributedString.string];
    while (presenceEventRange.location != NSNotFound) {
        
        UIColor *presenceEventColor = [self colorForPresenceEventInRange:presenceEventRange forString:attributedString.string];
        [attributedString addAttribute:NSForegroundColorAttributeName value:presenceEventColor range:presenceEventRange];
        NSInteger targetLocation = (presenceEventRange.location + presenceEventRange.length);
        searchRange = NSMakeRange(targetLocation, (searchLength - targetLocation));
        presenceEventRange = [self presenceEventRangeInRange:searchRange forString:attributedString.string];
    }
}

- (void)formatDatesIn:(NSMutableAttributedString *)attributedString {
    
    UIFont *tokenFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    NSInteger searchLength = [attributedString.string length];
    NSRange searchRange = NSMakeRange(0, searchLength);
    NSRange dateTokenRange = [self dateRangeInRange:searchRange forString:attributedString.string];
    while (dateTokenRange.location != NSNotFound) {
        
        [attributedString addAttribute:NSFontAttributeName value:tokenFont range:dateTokenRange];
        NSInteger targetLocation = (dateTokenRange.location + dateTokenRange.length);
        searchRange = NSMakeRange(targetLocation, (searchLength - targetLocation));
        dateTokenRange = [self dateRangeInRange:searchRange forString:attributedString.string];
    }
}


#pragma mark - Misc methods

- (NSRange)presenceEventRangeInRange:(NSRange)searchRange forString:(NSString *)string {
    
    return [string rangeOfString:@"<[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}>.+(joined|leaved|timeout)"
                         options:NSRegularExpressionSearch range:searchRange];
}

- (UIColor *)colorForPresenceEventInRange:(NSRange)searchRange forString:(NSString *)string {
    
    UIColor *color = [UIColor colorWithRed:(64.0f/255.0f) green:(176.0f/255.0f) blue:(73.0f/255.0f) alpha:1.0f];
    NSString *substring = [string substringWithRange:searchRange];
    if ([substring rangeOfString:@"leaved"].location != NSNotFound) {
        
        color = [UIColor darkGrayColor];
    }
    if ([substring rangeOfString:@"timeout"].location != NSNotFound) {
        
        color = [UIColor colorWithRed:(198.0f/255.0f) green:(34.0f/255.0f) blue:(41.0f/255.0f) alpha:1.0f];
    }
    
    
    return color;
}

- (NSRange)dateRangeInRange:(NSRange)searchRange forString:(NSString *)string {
    
    return [string rangeOfString:@"(<[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}>)"
                         options:NSRegularExpressionSearch range:searchRange];
}

#pragma mark -


@end
