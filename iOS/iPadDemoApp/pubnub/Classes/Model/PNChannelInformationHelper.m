//
//  PNChannelInformationHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelInformationHelper.h"
#import "PNChannelInformationHelperDelegate.h"
#import "NSDictionary+PNDemoAddition.h"


#pragma mark Private interface declaration

@interface PNChannelInformationHelper () <UITextViewDelegate, UITextFieldDelegate>


#pragma mark - Property

/**
 Stores reference on delegate which will handle all events which is related to channel information change and input.
 */
@property (nonatomic, pn_desired_weak) IBOutlet id<PNChannelInformationHelperDelegate> delegate;

/**
 Stores reference on field which will hold channel name and allow to change it (in case if channel not subscribed on it).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectNameField;

/**
 @brief Reference on field which will hold channel namespace name and allow to change it (in case if not subscribed on it).
 
 @since 3.7.0
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectNamespaceField;

/**
 Stores reference on original state (assigned at the moment when state set for first time).
 */
@property (nonatomic, strong) NSDictionary *originalState;

/**
 Stores whether malformed client state has been provided or not.
 */
@property (nonatomic, assign, getter = isValidObjectStateProvided) BOOL validObjectStateProvided;


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
    
    self.validObjectStateProvided = YES;
}

- (void)setState:(NSDictionary *)state {
    
    _state = state;
    if (self.originalState == nil && state != nil) {
        
        self.originalState = state;
    }
}

- (id<PNChannelProtocol>)object {
    
    id <PNChannelProtocol> object = nil;
    if (_object) {
        
        object = _object;
    }
    else {
        
        if ([self canCreateObject]) {
            
            BOOL hasVaildName = self.objectName && ![self.objectName pn_isEmpty];
            BOOL hasVaildNamespace = self.objectNamespace && ![self.objectNamespace pn_isEmpty];
            if (self.objectNamespaceField) {
                
                if (hasVaildName || hasVaildNamespace) {
                    
                    object = [PNChannelGroup channelGroupWithName:self.objectName inNamespace:self.objectNamespace
                                            shouldObservePresence:self.observePresence];
                }
            }
            else if(hasVaildName) {
                
                object = [PNChannel channelWithName:self.objectName shouldObservePresence:self.shouldObservePresence];
            }
        }
    }
    
    
    return object;
}

- (BOOL)canCreateObject {
    
    BOOL canCreateObject = (self.objectName ? ![self.objectName pn_isEmpty] : NO);
    if (self.objectNamespaceField) {
        
        canCreateObject = (!canCreateObject ? (self.objectNamespace ? ![self.objectNamespace pn_isEmpty] : NO) : canCreateObject);
    }
    if (canCreateObject && self.state != nil) {
        
        canCreateObject = [self.state isKindOfClass:[NSDictionary class]];
    }
    
    
    return canCreateObject;
}

- (BOOL)shouldChangePresenceObservationState {
    
    BOOL shouldChangePresenceObservationState = NO;
    id <PNChannelProtocol> object = _object;
    if (object && [PubNub isSubscribedOn:object]) {
        
        shouldChangePresenceObservationState = self.shouldObservePresence != [PubNub isPresenceObservationEnabledFor:object];
    }
    
    
    return shouldChangePresenceObservationState;
}

- (BOOL)shouldChangeObjectState {
    
    BOOL shouldChangeChannelState = NO;
    id <PNChannelProtocol> object = _object;
    if (object && [PubNub isSubscribedOn:object]) {
        
        shouldChangeChannelState = [self.state isEqualToDictionary:self.originalState];
    }
    
    
    return shouldChangeChannelState;
}

- (BOOL)isObjectStateValid {
    
    BOOL isObjectStateValid = YES;
    if ([self canCreateObject]) {
        
        // Checking whether user provided suitable object state data or not.
        if (self.isValidObjectStateProvided) {
            
            // Checking whether user provided some data or not
            if (self.state) {
                
                isObjectStateValid = [@{@"" : self.state} pn_isValidState];
            }
        }
        else {
            
            isObjectStateValid = NO;
        }
    }
    
    
    return isObjectStateValid;
}

- (BOOL)isObjectInformationChanged {
    
    BOOL isChannelInformationChanged = [self shouldChangePresenceObservationState];
    if (!isChannelInformationChanged) {
        
        isChannelInformationChanged = [self.state isEqualToDictionary:self.originalState];
    }
    
    
    return isChannelInformationChanged;
}

- (void)resetWarnings {
    
    self.validObjectStateProvided = YES;
}

#pragma mark - Handler methods

- (IBAction)handlePresenceObservationStateChange:(id)sender {
    
    self.observePresence = ((UISwitch *)sender).isOn;
    [self.delegate channelInformationDidChange];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.objectNameField]) {
        
        self.objectName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else {
        
        self.objectNamespace = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self.delegate channelNameDidChange];
    
    
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

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
    
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView.text.length > 0) {
        
        NSError *serializationError;
        NSDictionary *state = [NSJSONSerialization JSONObjectWithData:[textView.text dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:(NSJSONReadingOptions)0 error:&serializationError];
        if (!serializationError && state) {
            
            self.validObjectStateProvided = YES;
            self.state = [state count] ? state : nil;
        }
        else {
            
            self.validObjectStateProvided = NO;
        }
    }
    else {
        
        self.state = nil;
        self.validObjectStateProvided = YES;
    }
    
    
    [self.delegate channelInformationDidChange];
}

#pragma mark -


@end
