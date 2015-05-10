//
//  KodiCommands.m
//  Kodi Remote
//
//  Created by Luis Fernandes on 10/05/2015.
//  Copyright (c) 2015 joethefox inc. All rights reserved.
//

#import "KodiCommands.h"
#import <WatchKit/WatchKit.h>
#import "GlobalData.h"
#import "DSJSONRPC.h"

@interface KodiCommands()
@property (nonatomic) int lastServer;
@property (nonatomic, strong) DSJSONRPC *jsonRPC;
@end

@implementation KodiCommands
@synthesize serverList;
@synthesize lastServer;
@synthesize jsonRPC;

@synthesize serverOnLine;
@synthesize serverTCPConnectionOpen;
@synthesize serverVersion;
@synthesize serverMinorVersion;
@synthesize serverVolume;
@synthesize serverName;

static KodiCommands *instance =nil;
+ (KodiCommands *)getInstance {
    @synchronized(self){
        if(instance==nil){
            instance = [[KodiCommands alloc] init];
            [instance initServer];
        }
    }
    return instance;
}

- (void)initServer {
    [WKInterfaceController openParentApplication:[NSDictionary dictionaryWithObjectsAndKeys:nil] reply:^(NSDictionary *replyInfo, NSError *error) {
        NSMutableArray *servers = replyInfo[@"servers"];
        lastServer = [replyInfo[@"lastServer"] intValue];
        [self setServerList:servers];
        [self selectServer:lastServer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServersUpdated" object:nil userInfo:nil];
    }];
}

static inline BOOL IsEmpty(id obj) {
    return obj == nil
    || ([obj respondsToSelector:@selector(length)]
        && [(NSData *)obj length] == 0)
    || ([obj respondsToSelector:@selector(count)]
        && [(NSArray *)obj count] == 0);
}

- (void)selectServer:(NSInteger)index {
    GlobalData *obj=[GlobalData getInstance];
    NSDictionary *item = [serverList objectAtIndex:index];
    obj.serverDescription = IsEmpty([item objectForKey:@"serverDescription"]) ? @"" : [item objectForKey:@"serverDescription"];
    obj.serverUser = IsEmpty([item objectForKey:@"serverUser"]) ? @"" : [item objectForKey:@"serverUser"];
    obj.serverPass = IsEmpty([item objectForKey:@"serverPass"]) ? @"" : [item objectForKey:@"serverPass"];
    obj.serverIP = IsEmpty([item objectForKey:@"serverIP"]) ? @"" : [item objectForKey:@"serverIP"];
    obj.serverPort = IsEmpty([item objectForKey:@"serverPort"]) ? @"" : [item objectForKey:@"serverPort"];
    obj.serverHWAddr = IsEmpty([item objectForKey:@"serverMacAddress"]) ? @"" : [item objectForKey:@"serverMacAddress"];
    obj.preferTVPosters = [[item objectForKey:@"preferTVPosters"] boolValue];
    obj.tcpPort = [[item objectForKey:@"tcpPort"] intValue];
    jsonRPC = nil;
    [self checkServer];
}

-(void)GUIAction:(NSString *)action params:(NSDictionary *)params httpAPIcallback:(NSString *)callback{
    GlobalData *obj=[GlobalData getInstance];
    NSString *userPassword=[obj.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", obj.serverPass];
    NSString *serverJSON=[NSString stringWithFormat:@"http://%@%@@%@:%@/jsonrpc", obj.serverUser, userPassword, obj.serverIP, obj.serverPort];
    jsonRPC = [[DSJSONRPC alloc] initWithServiceEndpoint:[NSURL URLWithString:serverJSON]];
    [jsonRPC callMethod:action withParameters:params onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
        //        NSLog(@"Action %@ ok with %@ ", action , methodResult);
        //        if (methodError!=nil || error != nil){
        //            NSLog(@"method error %@ %@", methodError, error);
        //        }
        if ((methodError!=nil || error != nil) && callback!=nil){ // Backward compatibility
            [self sendXbmcHttp:callback];
        }
    }];
}

-(void)sendXbmcHttp:(NSString *) command{
    GlobalData *obj=[GlobalData getInstance];
    NSString *userPassword=[obj.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", obj.serverPass];
    
    NSString *serverHTTP=[NSString stringWithFormat:@"http://%@%@@%@:%@/xbmcCmds/xbmcHttp?command=%@", obj.serverUser, userPassword, obj.serverIP, obj.serverPort, command];
    NSURL *url = [NSURL  URLWithString:serverHTTP];
    NSString *requestANS = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    requestANS=nil;
}

-(void)playbackAction:(NSString *)action params:(NSArray *)parameters{
    jsonRPC = nil;
    GlobalData *obj=[GlobalData getInstance];
    NSString *userPassword=[obj.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", obj.serverPass];
    NSString *serverJSON=[NSString stringWithFormat:@"http://%@%@@%@:%@/jsonrpc", obj.serverUser, userPassword, obj.serverIP, obj.serverPort];
    jsonRPC = [[DSJSONRPC alloc] initWithServiceEndpoint:[NSURL URLWithString:serverJSON]];
    [jsonRPC callMethod:@"Player.GetActivePlayers" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
        if (error==nil && methodError==nil){
            if( [methodResult count] > 0){
                NSNumber *response = [[methodResult objectAtIndex:0] objectForKey:@"playerid"];
                NSMutableArray *commonParams=[NSMutableArray arrayWithObjects:response, @"playerid", nil];
                if (parameters!=nil)
                    [commonParams addObjectsFromArray:parameters];
                [jsonRPC callMethod:action withParameters:[self indexKeyedDictionaryFromArray:commonParams] onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
                    //                    if (error==nil && methodError==nil){
                    //                        NSLog(@"comando %@ eseguito. Risultato: %@", action, methodResult);
                    //                    }
                    //                    else {
                    //                        NSLog(@"ci deve essere un secondo problema %@", methodError);
                    //                    }
                }];
            }
        }
        //        else {
        //            NSLog(@"ci deve essere un primo problema %@", methodError);
        //        }
    }];
}

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    NSInteger numelement=[array count];
    for (int i=0;i<numelement-1;i+=2){
        [mutableDictionary setObject:[array objectAtIndex:i] forKey:[array objectAtIndex:i+1]];
    }
    return (NSDictionary *)mutableDictionary;
}

- (void)playerStep:(NSString *)step musicPlayerGo:(NSString *)musicAction{
    if (serverVersion > 11){
        if (jsonRPC == nil){
            GlobalData *obj=[GlobalData getInstance];
            NSString *userPassword=[obj.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", obj.serverPass];
            NSString *serverJSON=[NSString stringWithFormat:@"http://%@%@@%@:%@/jsonrpc", obj.serverUser, userPassword, obj.serverIP, obj.serverPort];
            jsonRPC = [[DSJSONRPC alloc] initWithServiceEndpoint:[NSURL URLWithString:serverJSON]];
        }
        
        ;
        [jsonRPC
         callMethod:@"GUI.GetProperties"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                         [[NSArray alloc] initWithObjects:@"currentwindow", @"fullscreen",nil], @"properties",
                         nil]
         onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
             if (error==nil && methodError==nil && [methodResult isKindOfClass: [NSDictionary class]]){
                 int winID = 0;
                 NSNumber *fullscreen = 0;
                 if (((NSNull *)[methodResult objectForKey:@"fullscreen"] != [NSNull null])){
                     fullscreen = [methodResult objectForKey:@"fullscreen"];
                 }
                 if (((NSNull *)[methodResult objectForKey:@"currentwindow"] != [NSNull null])){
                     winID = [[[methodResult objectForKey:@"currentwindow"] objectForKey:@"id"] intValue];
                 }
                 // 12005: WINDOW_FULLSCREEN_VIDEO
                 // 12006: WINDOW_VISUALISATION
                 if ([fullscreen boolValue] == YES && (winID == 12005 || winID == 12006)){
                     [jsonRPC
                      callMethod:@"XBMC.GetInfoBooleans"
                      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSArray alloc] initWithObjects:@"VideoPlayer.HasMenu", @"Pvr.IsPlayingTv", nil], @"booleans",
                                      nil]
                      onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
                          if (error==nil && methodError==nil && [methodResult isKindOfClass: [NSDictionary class]]){
                              NSNumber *VideoPlayerHasMenu = 0;
                              NSNumber *PvrIsPlayingTv = 0;
                              if (((NSNull *)[methodResult objectForKey:@"VideoPlayer.HasMenu"] != [NSNull null])){
                                  VideoPlayerHasMenu = [methodResult objectForKey:@"VideoPlayer.HasMenu"];
                              }
                              if (((NSNull *)[methodResult objectForKey:@"Pvr.IsPlayingTv"] != [NSNull null])){
                                  PvrIsPlayingTv = [methodResult objectForKey:@"Pvr.IsPlayingTv"];
                              }
                              if (winID == 12005  && [PvrIsPlayingTv boolValue] == NO && [VideoPlayerHasMenu boolValue] == NO){
                                  [self playbackAction:@"Player.Seek" params:[NSArray arrayWithObjects:step, @"value", nil]];
                              }
                              else if (winID == 12006 && musicAction != nil){
                                  [self playbackAction:@"Player.GoTo" params:[NSArray arrayWithObjects:musicAction, @"to", nil]];
                              }
                          }
                      }];
                 }
             }
         }];
    }
    return;
}

- (void)checkServer{
    jsonRPC=nil;
    GlobalData *serverData = [GlobalData getInstance];
    if ([serverData.serverIP length] == 0){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"showSetup", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TcpJSONRPCShowSetup" object:nil userInfo:params];
        if (serverOnLine){
            //[self noConnectionNotifications];
        }
        return;
    }
    
    NSString *userPassword = [serverData.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", serverData.serverPass];
    NSString *serverJSON = [NSString stringWithFormat:@"http://%@%@@%@:%@/jsonrpc", serverData.serverUser, userPassword, serverData.serverIP, serverData.serverPort];
    jsonRPC = [[DSJSONRPC alloc] initWithServiceEndpoint:[NSURL URLWithString:serverJSON]];
    NSDictionary *checkServerParams = [NSDictionary dictionaryWithObjectsAndKeys: [[NSArray alloc] initWithObjects:@"version", @"volume", nil], @"properties", nil];
    [jsonRPC
     callMethod:@"Application.GetProperties"
     withParameters:checkServerParams
     withTimeout: 2.0f
     onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, DSJSONRPCError *methodError, NSError* error) {
         if (error==nil && methodError==nil){
             serverVolume = [[methodResult objectForKey:@"volume"] intValue];
             if (!serverOnLine){
                 if( [NSJSONSerialization isValidJSONObject:methodResult]){
                     NSDictionary *serverInfo=[methodResult objectForKey:@"version"];
                     serverVersion = [[serverInfo objectForKey:@"major"] intValue];
                     serverMinorVersion = [[serverInfo objectForKey:@"minor"] intValue];
                     NSString *infoTitle=[NSString stringWithFormat:@"%@ v%@.%@ %@",
                                          serverData.serverDescription,
                                          [serverInfo objectForKey:@"major"],
                                          [serverInfo objectForKey:@"minor"],
                                          [serverInfo objectForKey:@"tag"]];//, [serverInfo objectForKey:@"revision"]
                     NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES], @"status",
                                             infoTitle, @"message",
                                             nil];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"TcpJSONRPCChangeServerStatus" object:nil userInfo:params];
                     params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"showSetup", nil];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"TcpJSONRPCShowSetup" object:nil userInfo:params];
                 }
                 else{
                     if (serverOnLine){
                         //[self noConnectionNotifications];
                     }
                     NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"showSetup", nil];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"TcpJSONRPCShowSetup" object:nil userInfo:params];
                 }
             }
         }
         else {
             serverVolume = -1;
             if (serverOnLine){
                 //[self noConnectionNotifications];
             }
             NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"showSetup", nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"TcpJSONRPCShowSetup" object:nil userInfo:params];
         }
     }];
    jsonRPC=nil;
}


@end
