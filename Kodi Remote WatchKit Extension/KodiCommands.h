//
//  KodiCommands.h
//  Kodi Remote
//
//  Created by Luis Fernandes on 10/05/2015.
//  Copyright (c) 2015 joethefox inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KodiCommands : NSObject
@property (nonatomic, readwrite) NSMutableArray *serverList;
@property (nonatomic, assign) BOOL serverOnLine;
@property (nonatomic, assign) BOOL serverTCPConnectionOpen;
@property (nonatomic, assign) int serverVersion;
@property (nonatomic, assign) int serverMinorVersion;
@property (nonatomic, assign) int serverVolume;
@property (retain, nonatomic) NSString *serverName;

+ (KodiCommands *)getInstance;
- (void)initServer;
- (void)selectServer:(NSInteger)index;
- (void)GUIAction:(NSString *)action params:(NSDictionary *)params httpAPIcallback:(NSString *)callback;
- (void)playerStep:(NSString *)step musicPlayerGo:(NSString *)musicAction;
@end
