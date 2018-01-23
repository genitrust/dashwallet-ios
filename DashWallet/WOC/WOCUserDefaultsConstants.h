//
//  WOCUserDefaultsConstants.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#ifndef WOCUserDefaultsConstants_h
#define WOCUserDefaultsConstants_h

#ifdef SHOW_LOGS
#define APILog(x, ...) NSLog(@"\n\n%s %d: \n" x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define APILog(x, ...)
#endif
#define Str(str) (str != [NSNull null])?str:@""

#define WALLOFCOINS_PUBLISHER_ID 52

#endif /* WOCUserDefaultsConstants_h */
