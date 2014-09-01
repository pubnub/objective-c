//
//  PNChannelInformationHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelInformationHelper.h"
#import "PNChannelInformationHelperDelegate.h"

// Don't use this category on your own, because interface can be changed (private).
#import "NSDictionary+PNAdditions.h"


#pragma mark Private interface declaration

@interface PNChannelInformationHelper () <UITextViewDelegate, UITextFieldDelegate>


#pragma mark - Property

/**
 Stores reference on delegate which will handle all events which is related to channel information change and input.
 */
@property (nonatomic, pn_desired_weak) IBOutlet id<PNChannelInformationHelperDelegate> delegate;

/**
 Stores reference on original state (assigned at the moment when state set for first time).
 */
@property (nonatomic, strong) NSDictionary *originalState;

/**
 Stores whether malformed client state has been provided or not.
 */
@property (nonatomic, assign, getter = isValidChannelStateProvided) BOOL validChannelStateProvided;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (IBAction)handlePresenceObservationStateChange:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelInformationHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    self.validChannelStateProvided = YES;
}

- (void)setState:(NSDictionary *)state {
    
    _state = state;
    if (self.originalState == nil && state != nil) {
        
        self.originalState = state;
    }
}

- (BOOL)canCreateChannel {
    
    BOOL canCreateChannel = (self.channelName ? ![self.channelName pn_isEmpty] : NO);
    if (canCreateChannel && self.state != nil) {
        
        canCreateChannel = [self.state isKindOfClass:[NSDictionary class]];
    }
    
    
    return canCreateChannel;
}

- (BOOL)shouldChangePresenceObservationState {
    
    BOOL shouldChangePresenceObservationState = NO;
    PNChannel *channel = (self.channelName && ![self.channelName pn_isEmpty] ? [PNChannel channelWithName:self.channelName] : nil);
    if (channel && [PubNub isSubscribedOnChannel:channel]) {
        
        shouldChangePresenceObservationState = self.observePresence != [PubNub isPresenceObservationEnabledForChannel:channel];
    }
    
    
    return shouldChangePresenceObservationState;
}

- (BOOL)shouldChangeChannelState {
    
    BOOL shouldChangeChannelState = NO;
    PNChannel *channel = (self.channelName && ![self.channelName pn_isEmpty] ? [PNChannel channelWithName:self.channelName] : nil);
    if (channel && [PubNub isSubscribedOnChannel:channel]) {
        
        shouldChangeChannelState = [self.state isEqualToDictionary:self.originalState];
    }
    
    
    return shouldChangeChannelState;
}

- (BOOL)isChannelStateValid {
    
    BOOL isChannelStateValid = YES;
    if (self.channelName) {
        
        // Checking whether user provided suitable channel state data or not.
        if (self.isValidChannelStateProvided) {
            
            // Checking whether user provided some data or not
            if (self.state) {
                
                isChannelStateValid = [@{self.channelName : self.state} pn_isValidState];
            }
        }
        else {
            
            isChannelStateValid = NO;
        }
    }
    
    
    return isChannelStateValid;
}

- (BOOL)isChannelInformationChanged {
    
    BOOL isChannelInformationChanged = [self shouldChangePresenceObservationState];
    if (!isChannelInformationChanged) {
        
        isChannelInformationChanged = [self.state isEqualToDictionary:self.originalState];
    }
    
    
    return isChannelInformationChanged;
}

- (void)resetWarnings {
    
    self.validChannelStateProvided = YES;
}

#pragma mark - Handler methods

- (IBAction)handlePresenceObservationStateChange:(id)sender {
    
    self.observePresence = ((UISwitch *)sender).isOn;
    [self.delegate channelInformationDidChange];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    self.channelName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.delegate channelNameDidChange];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    
    return YES;
}


#pragma mark - UITextView delegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    BOOL shouldHandleByDefault = YES;
    if ([text length] == 1) {
        
        if ([text isEqualToString:@"{"] || [text isEqualToString:@"\""]) {
                
            NSRange caretPosition = NSMakeRange(range.location, 0);
            NSMutableString *finalString = [NSMutableString stringWithString:text];
            
            shouldHandleByDefault = NO;
            caretPosition.location = caretPosition.location + 1;
            [finalString appendString:([text isEqualToString:@"{"] ? @"}" : @"\"")];
            textView.text = [textView.text stringByReplacingCharactersInRange:range withString:finalString];
            textView.selectedRange = caretPosition;
        }
    }
    
    return shouldHandleByDefault;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView.text.length > 0) {
        
        NSError *serializationError;
        NSDictionary *state = [NSJSONSerialization JSONObjectWithData:[textView.text dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:(NSJSONReadingOptions)0 error:&serializationError];
        if (!serializationError && state) {
            
            self.validChannelStateProvided = YES;
            self.state = [state count] ? state : nil;
        }
        else {
            
            self.validChannelStateProvided = NO;
        }
    }
    else {
        
        self.state = nil;
        self.validChannelStateProvided = YES;
    }
    
    
    [self.delegate channelInformationDidChange];
}

#pragma mark -


@end
