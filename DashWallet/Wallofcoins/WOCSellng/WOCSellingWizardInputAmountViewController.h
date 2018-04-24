//
//  WOCSellingWizardInputAmountViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
//WOCSellingWizardInputAmountViewController
// Get Offer with Amount 
@interface WOCSellingWizardInputAmountViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *bankId;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSDictionary *bankDict;

@property (weak, nonatomic) IBOutlet UITextField *txtDash;
@property (weak, nonatomic) IBOutlet UITextField *txtDollar;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Height;
@property (weak, nonatomic) IBOutlet UIButton *btnGetOffers;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

- (IBAction)getOffersClicked:(id)sender;

@end
