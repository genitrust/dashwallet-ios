//
//  WOCSellingAdsInstructionsViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Enter Phone Number Screen
@interface WOCSellingAdsInstructionsViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *accountInfoStr;
@property (strong, nonatomic) NSString *currentPriceStr;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountCode;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountName;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAvailableCrypto;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) NSString *AdId;
- (IBAction)backToHomeScreenAction:(id)sender;

@end
