//
//  WOCBuyDashStep2ViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashStep2ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (assign) BOOL isZipCodeBlank;

- (IBAction)nextClicked:(id)sender;

@end
