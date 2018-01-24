//
//  WOCBuyDashStep3ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashStep3ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPaymentCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)nextClicked:(id)sender;
@end
