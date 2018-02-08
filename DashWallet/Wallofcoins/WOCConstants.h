//
//  WOCConstants.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#ifndef WOCConstants_h
#define WOCConstants_h

#ifdef SHOW_LOGS
#define APILog(x, ...) NSLog(@"\n\n%s %d: \n" x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define APILog(x, ...)
#endif
#define Str(str) (str != [NSNull null])?str:@""

#define WALLOFCOINS_PUBLISHER_ID "52"

//#define IS_PRODUCTION TRUE // IF MAINNET SET DASH_TESTNET = 0
#define IS_PRODUCTION FALSE  //  IF TESTNET SET DASH_TESTNET = 1

#define BASE_URL_PRODUCTION @"https://wallofcoins.com"
#define BASE_URL_DEVELOPMENT @"https://wallofcoins.com"

#define kHeaderPublisherId @"publisher-id"
#define kDeviceCode @"deviceCode"
#define kDeviceId @"deviceId"
#define kToken @"token"
#define kPhone @"phone"
#define kCountryCode @"countryCode"
#define kLaunchStatus @"first"

#endif /* WOCUserDefaultsConstants_h */
