//
//  WOCBaseViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/02/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOCDefaultBaseViewController.h"

@interface WOCBaseViewController : WOCDefaultBaseViewController

- (IBAction)signOutClicked:(id)sender;

- (void)loginWOC;
- (void)signOutWOC;
- (void)refereshToken;
- (void)pushToWOCRoot;
- (void)getOrderList;
- (NSString*)getDeviceIDFromPhoneNumber:(NSString*)phoneNo;
@end
