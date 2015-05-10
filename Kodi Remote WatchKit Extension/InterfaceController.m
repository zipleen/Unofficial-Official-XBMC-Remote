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
@property (nonatomic, weak) KodiCommands *kodiCommands;
@end


@implementation InterfaceController
@synthesize kodiCommands;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverUpdated:)
                                                 name:@"ServersUpdated"
                                               object:nil];
    
    kodiCommands = [KodiCommands getInstance];
    
    // Configure interface objects here.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)serverUpdated:(NSNotification*)note {
    [self setTitle:[GlobalData getInstance].serverDescription];
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
    [kodiCommands GUIAction:@"Input.Right" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
    [kodiCommands playerStep:@"smallforward" musicPlayerGo:@"next"];
}
- (IBAction)remoteUp {
    [kodiCommands GUIAction:@"Input.Up" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
    [kodiCommands playerStep:@"bigforward" musicPlayerGo:nil];
}
- (IBAction)remoteLeft {
    [kodiCommands GUIAction:@"Input.Left" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
    [kodiCommands playerStep:@"smallbackward" musicPlayerGo:@"previous"];
}
- (IBAction)remoteDown {
    [kodiCommands GUIAction:@"Input.Down" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
    [kodiCommands playerStep:@"bigbackward" musicPlayerGo:nil];
}
- (IBAction)remoteEnter {
    [kodiCommands GUIAction:@"Input.Select" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}
- (IBAction)remoteBack {
    [kodiCommands GUIAction:@"Input.Back" params:[NSDictionary dictionaryWithObjectsAndKeys:nil] httpAPIcallback:nil];
}

@end



