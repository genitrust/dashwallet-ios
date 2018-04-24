//
//  WOCSellingWizardHomeViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"


//WOCSellingWizardHomeViewController
// Find My Location Screen
@interface WOCSellingWizardHomeViewController : WOCBaseViewController

@property (weak, nonatomic) IBOutlet UIView *signoutView;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;
@property (weak, nonatomic) IBOutlet UIButton *orderListBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnSellYourCrypto;
@property (assign) BOOL isFromSend;

- (void)setLogoutButton;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)signOutClicked:(id)sender;
- (IBAction)sellYourCryptoClicked:(id)sender;

@end
