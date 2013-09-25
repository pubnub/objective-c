//
//  DetailViewController.h
//  pubNubBackgroundMediator
//
//  Created by Valentin Tuller on 9/25/13.
//  Copyright (c) 2013 Valentin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
