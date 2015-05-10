//
//  InterfaceController.m
//  Kodi Remote WatchKit Extension
//
//  Created by Luis Fernandes on 09/05/2015.
//  Copyright (c) 2015 joethefox inc. All rights reserved.
//

#import "InterfaceController.h"
#import "KodiCommands.h"
#import "GlobalData.h"

@interface InterfaceController()
@property (nonatomic, readwrite) NSMutableArray *arrayServerList;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self initServer];
    // Configure interface objects here.
}

- (void)initServer {
    [WKInterfaceController openParentApplication:[NSDictionary dictionaryWithObjectsAndKeys:nil] reply:^(NSDictionary *replyInfo, NSError *error) {
        NSMutableArray *servers = replyInfo[@"servers"];
        [self setArrayServerList:servers];
        [self selectServer:[replyInfo[@"lastServer"] integerValue]];
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
    NSDictionary *item = [_arrayServerList objectAtIndex:index];
    obj.serverDescription = IsEmpty([item objectForKey:@"serverDescription"]) ? @"" : [item objectForKey:@"serverDescription"];
    obj.serverUser = IsEmpty([item objectForKey:@"serverUser"]) ? @"" : [item objectForKey:@"serverUser"];
    obj.serverPass = IsEmpty([item objectForKey:@"serverPass"]) ? @"" : [item objectForKey:@"serverPass"];
    obj.serverIP = IsEmpty([item objectForKey:@"serverIP"]) ? @"" : [item objectForKey:@"serverIP"];
    obj.serverPort = IsEmpty([item objectForKey:@"serverPort"]) ? @"" : [item objectForKey:@"serverPort"];
    obj.serverHWAddr = IsEmpty([item objectForKey:@"serverMacAddress"]) ? @"" : [item objectForKey:@"serverMacAddress"];
    obj.preferTVPosters = [[item objectForKey:@"preferTVPosters"] boolValue];
    obj.tcpPort = [[item objectForKey:@"tcpPort"] intValue];
    [self setTitle:obj.serverDescription];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
- (IBAction)remoteRight {
    [KodiCommands GUIAction:@"Input.Right" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteUp {
    [KodiCommands GUIAction:@"Input.Up" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteLeft {
    [KodiCommands GUIAction:@"Input.Left" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteDown {
    [KodiCommands GUIAction:@"Input.Down" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteEnter {
    [KodiCommands GUIAction:@"Input.Select" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteBack {
    [KodiCommands GUIAction:@"Input.Back" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}

@end



