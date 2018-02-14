//
//  WOCBuyDashStep1ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashStep1ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnNoThanks;
@property (assign) BOOL isFromSend;

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)findLocationClicked:(id)sender;
- (IBAction)noThanksClicked:(id)sender;

@end
