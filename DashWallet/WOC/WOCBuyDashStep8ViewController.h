//
//  WOCBuyDashStep8ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashStep8ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPurchaseCode;
@property (weak, nonatomic) IBOutlet UIButton *btnPurchaseCode;
- (IBAction)confirmPurchaseCodeClicked:(id)sender;
@end
