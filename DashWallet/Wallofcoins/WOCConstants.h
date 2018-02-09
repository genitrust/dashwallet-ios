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

#define BASE_URL_DEVELOPMENT @"https://wallofcoins.com"
#define BASE_URL_PRODUCTION @"https://wallofcoins.com"

#define API_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define LOCAL_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define kHeaderPublisherId @"X-Coins-Publisher"
#define kDeviceCode @"deviceCode"
#define kDeviceId @"deviceId"
#define kToken @"token"
#define kPhone @"phone"
#define kCountryCode @"countryCode"
#define kLaunchStatus @"first"

#define kNotificationObserverStep2Id @"openBuyDashStep2"
#define kNotificationObserverStep4Id @"openBuyDashStep4"
#define kNotificationObserverStep8Id @"openBuyDashStep8"

#define kLocationLatitude @"locationLatitude"
#define kLocationLongitude @"locationLongitude"

#pragma mark - API Body Keys
#define kPublisherId @"publisherId"
#define kCryptoAmount @"cryptoAmount"
#define kUsdAmount @"usdAmount"
#define kCrypto @"crypto"
#define kCryptoAddress @"cryptoAddress"
#define kBank @"bank"
#define kZipCode @"zipCode"

#define kOffer @"offer"
#define kDeviceName @"deviceName"
#define kDeviceNameIOS @"Dash Wallet (iOS)"
#define kEmail @"email"
#define kJSONParameter @"JSONPara"

#define kVerificationCode @"verificationCode"
#define kPassword @"password"

#endif /* WOCUserDefaultsConstants_h */
