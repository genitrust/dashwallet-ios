//
//  WOCBuyingInstructionsViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyingInstructionsViewController : UIViewController

@property (strong, nonatomic) NSString *purchaseCode;
@property (strong, nonatomic) NSString *holdId;
@property (strong, nonatomic) NSString *phoneNo;
@property (strong, nonatomic) NSDictionary *orderDict;
@property (assign) BOOL isFromSend;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *lblBankName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
- (IBAction)showMapClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblAccountName;
@property (weak, nonatomic) IBOutlet UILabel *lblAccountNo;
@property (weak, nonatomic) IBOutlet UILabel *lblCashDeposit;
@property (weak, nonatomic) IBOutlet UILabel *lblDepositDue;

@property (weak, nonatomic) IBOutlet UIButton *btnDepositFinished;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelOrder;
- (IBAction)depositFinishedClicked:(id)sender;
- (IBAction)cancelOrderClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblInstructions;

@end
