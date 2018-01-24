//
//  WOCBuyDashStep4ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashStep4ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtDash;
@property (weak, nonatomic) IBOutlet UITextField *txtDollar;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Height;
@property (weak, nonatomic) IBOutlet UIButton *btnGetOffers;
- (IBAction)getOffersClicked:(id)sender;
@end
