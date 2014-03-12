//
//  CTTestEntryCell.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTestEntryCell.h"
#import "PNRoundedView.h"
#import "CTTest.h"


#pragma mark Private interface declaration

@interface CTTestEntryCell ()

#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *checkmarkLabel;
@property (nonatomic, pn_desired_weak) IBOutlet PNRoundedView *statusMarkerView;
@property (nonatomic, strong) CTTest *test;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (IBAction)handleRunButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation CTTestEntryCell


#pragma mark - Instance methods

- (void)awakeFromNib {

    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
}

- (void)prepareForReuse {
    
    self.test = nil;
    self.textLabel.text = nil;
}

- (void)updateWithTest:(CTTest *)test {
    
    self.test = test;
    self.textLabel.text = test.caseDescription;
}

- (void)setMarked:(BOOL)marked {
    
    _marked = marked;
    self.checkmarkLabel.hidden = !marked;
}

- (void)setState:(CTTestState)state {
    
    _state = state;
    UIColor *stateColor = [UIColor colorWithRed:(212.0f/255.0f) green:(212.0f/255.0f) blue:(212.0f/255.0f) alpha:1.0f];
    if (state == CTTestPassedState) {
        
        stateColor = [UIColor colorWithRed:(87.0f/255.0f) green:(214.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
    }
    else if (state == CTTestFailedState) {
        
        stateColor = [UIColor colorWithRed:(198.0f/255.0f) green:(34.0f/255.0f) blue:(41.0f/255.0f) alpha:1.0f];
    }
    
    self.statusMarkerView.fillColor = stateColor;
    [self.statusMarkerView setNeedsDisplay];
}

#pragma mark - Handler methods

- (IBAction)handleRunButtonTap:(id)sender {
    
    [self.delegate didRunTest:self.test];
}

#pragma mark -


@end
