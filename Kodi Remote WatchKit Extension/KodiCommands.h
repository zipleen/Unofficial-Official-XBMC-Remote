//
//  KodiCommands.h
//  Kodi Remote
//
//  Created by Luis Fernandes on 10/05/2015.
//  Copyright (c) 2015 joethefox inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KodiCommands : NSObject
+(void)GUIAction:(NSString *)action params:(NSDictionary *)params httpAPIcallback:(NSString *)callback;
@end
