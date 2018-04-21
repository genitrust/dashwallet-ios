//
//  WOCBuyDashStep1ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Find My Location Screen
@interface WOCBuyDashStep1ViewController : WOCBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnNoThanks;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;
@property (weak, nonatomic) IBOutlet UIView *signoutView;
@property (weak, nonatomic) IBOutlet UIButton *orderListBtn;
@property (assign) BOOL isFromSend;

- (void)setLogoutButton;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)findLocationClicked:(id)sender;
- (IBAction)noThanksClicked:(id)sender;
- (IBAction)signOutClicked:(id)sender;

@end
