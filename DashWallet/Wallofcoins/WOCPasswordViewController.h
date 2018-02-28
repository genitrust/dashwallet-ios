//
//  WOCPasswordViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
@interface WOCPasswordViewController : WOCBaseViewController

@property (strong, nonatomic) NSString *offerId;
@property (strong, nonatomic) NSString *phoneNo;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *lblWOCLink;
@property (weak, nonatomic) IBOutlet UIButton *btnWOCLink;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;

- (IBAction)linkClicked:(id)sender;
- (IBAction)loginClicked:(id)sender;
- (IBAction)forgotPasswordClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;

@end
