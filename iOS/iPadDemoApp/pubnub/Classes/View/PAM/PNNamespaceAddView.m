//
//  PNNamespaceAddView.m
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNNamespaceAddView.h"
#import "NSString+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface delcaration

@interface PNNamespaceAddView () <UITextFieldDelegate>


#pragma mark - Properties

/**
 Stores reference on button which allow user to complete identifier input.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *addButton;

/**
 Stores reference on text field which allow user to input new identifier.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *namespaceNameTextField;

/**
 @brief Reference on resulting namespace name inputed by user.
 
 @since <#version number#>
 */
@property (nonatomic, copy) NSString *namespaceName;


#pragma mark - Instance methods

- (void)updateLayout;


#pragma mark - Handler methods

- (IBAction)handleAddButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNNamespaceAddView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self updateLayout];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)updateLayout {
    
    self.addButton.enabled = (self.namespaceName && ![self.namespaceName pn_isEmpty]);
}


#pragma mark - Handler methods

- (IBAction)handleAddButtonTap:(id)sender {
    
    [self.delegate namespaceView:self
            didEndNamespaceInput:[PNChannelGroupNamespace namespaceWithName:self.namespaceNameTextField.text]];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}


#pragma mark - UITextField delegate methods

- (BOOL)  textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
  replacementString:(NSString *)string {
    
    self.namespaceName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateLayout];
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}

#pragma mark -


@end
