//
//  WOCBuyDashStep7ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Enter Phone Number Screen
@interface WOCBuyDashStep7ViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *offerId;
@property (strong, nonatomic) NSString *emailId;
@property (assign, readwrite) BOOL isActiveHoldChecked;
@property (assign, readwrite) BOOL isForLoginOny;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *txtCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;

- (IBAction)nextClicked:(id)sender;

@end
