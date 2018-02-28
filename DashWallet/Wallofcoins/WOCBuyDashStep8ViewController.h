//
//  WOCBuyDashStep8ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
@interface WOCBuyDashStep8ViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *purchaseCode;
@property (strong, nonatomic) NSString *offerId;
@property (strong, nonatomic) NSString *holdId;
@property (strong, nonatomic) NSString *phoneNo;
@property (strong, nonatomic) NSString *emailId;
@property (strong, nonatomic) NSString *deviceCode;

@property (weak, nonatomic) IBOutlet UITextField *txtPurchaseCode;
@property (weak, nonatomic) IBOutlet UIButton *btnPurchaseCode;

- (IBAction)confirmPurchaseCodeClicked:(id)sender;

@end
