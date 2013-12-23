//
//  ViewController.h
//  demo9
//
//  Created by geremy cohen on 5/8/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)enablePush:(id)sender;
- (IBAction)disablePush:(id)sender;
- (IBAction)disableAllPush:(id)sender;
- (IBAction)auditPush:(id)sender;
- (IBAction)sendString:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *requestOutpu;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSData *deviceToken;

@end
