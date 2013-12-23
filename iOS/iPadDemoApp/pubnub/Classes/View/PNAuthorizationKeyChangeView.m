//
//  PNAuthorizationKeyChangeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/26/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAuthorizationKeyChangeView.h"


#pragma mark Private interface methods

@interface PNAuthorizationKeyChangeView () <UITextFieldDelegate>


#pragma mark Properties

// Stores reference on new authorization key input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *authorizationKey;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *changeButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *closeButton;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)changeButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;


@end


#pragma mark Public interface methods

@implementation PNAuthorizationKeyChangeView


#pragma mark - Class methods

+ (id)viewFromNib {
    
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward to the super class to complete intialization
    [super awakeFromNib];
    
    [self prepareInterface];
}


#pragma mark - Interface customization

- (void)prepareInterface {
    
    UIImage *stretchableButtonBackground = [[UIImage imageNamed:@"red-button.png"] stretchableImageWithLeftCapWidth:5.0f
                                                                                                       topCapHeight:5.0f];
    [self.changeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}


#pragma mark - Handler methods

- (IBAction)changeButtonTapped:(id)sender {
    
    [self.delegate authorizationKeyChangeView:self didChangeKeyTo:self.authorizationKey.text];
    [self removeFromSuperview];
}

- (IBAction)closeButtonTapped:(id)sender {
    
    [self removeFromSuperview];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *channelName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL entered = [[channelName stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
    self.changeButton.enabled = entered;
    
    
    return YES;
}


#pragma mark -


@end
