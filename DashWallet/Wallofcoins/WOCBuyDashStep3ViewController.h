//
//  WOCBuyDashStep3ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
@interface WOCBuyDashStep3ViewController : WOCBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPaymentCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)nextStepClicked:(id)sender;

@end
