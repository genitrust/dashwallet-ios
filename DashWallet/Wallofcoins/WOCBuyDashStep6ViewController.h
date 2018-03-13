//
//  WOCBuyDashStep6ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"

// Enter Email Address Screen
@interface WOCBuyDashStep6ViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *offerId;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

- (IBAction)doNotSendMeEmailClicked:(id)sender;
- (IBAction)nextClicked:(id)sender;

@end
