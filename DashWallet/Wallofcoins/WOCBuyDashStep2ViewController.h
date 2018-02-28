//
//  WOCBuyDashStep2ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCBaseViewController.h"
// Enter ZipCode
@interface WOCBuyDashStep2ViewController : WOCBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (assign) BOOL isZipCodeBlank;

- (IBAction)nextClicked:(id)sender;

@end
