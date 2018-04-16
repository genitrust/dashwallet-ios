//
//  WOCSellingAdvancedOptionsInstructionsViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Enter Phone Number Screen
@interface WOCSellingAdvancedOptionsInstructionsViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *accountInfoStr;
@property (strong, nonatomic) NSString *currentPriceStr;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountCode;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountName;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAvailableCrypto;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)nextClicked:(id)sender;

@property (strong, nonatomic) NSString *offerId;
@property (strong, nonatomic) NSString *emailId;
@property (assign, readwrite) BOOL isActiveHoldChecked;
@property (assign, readwrite) BOOL isForLoginOny;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmEmail;

@end
