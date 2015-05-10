//
//  KodiCommands.m
//  Kodi Remote
//
//  Created by Luis Fernandes on 10/05/2015.
//  Copyright (c) 2015 joethefox inc. All rights reserved.
//

#import "KodiCommands.h"
#import "GlobalData.h"
#import "DSJSONRPC.h"

@implementation KodiCommands
+(void)GUIAction:(NSString *)action params:(NSDictionary *)params httpAPIcallback:(NSString *)callback{
    DSJSONRPC *jsonRPC = nil;
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

+(void)sendXbmcHttp:(NSString *) command{
    GlobalData *obj=[GlobalData getInstance];
    NSString *userPassword=[obj.serverPass isEqualToString:@""] ? @"" : [NSString stringWithFormat:@":%@", obj.serverPass];
    
    NSString *serverHTTP=[NSString stringWithFormat:@"http://%@%@@%@:%@/xbmcCmds/xbmcHttp?command=%@", obj.serverUser, userPassword, obj.serverIP, obj.serverPort, command];
    NSURL *url = [NSURL  URLWithString:serverHTTP];
    NSString *requestANS = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    requestANS=nil;
}
@end
