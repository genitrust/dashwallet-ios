//
//  WOCPasswordViewController.h
//  dashwallet
//
//  Created by iMac03 on 27/01/18.
//  Copyright © 2018 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCPasswordViewController : UIViewController

@property (strong, nonatomic) NSString *offerId;
@property (strong, nonatomic) NSString *phoneNo;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *lblWOCLink;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
- (IBAction)loginClicked:(id)sender;
- (IBAction)forgotPasswordClicked:(id)sender;
@end
