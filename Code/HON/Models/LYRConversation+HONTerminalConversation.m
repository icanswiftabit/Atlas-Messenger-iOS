//
//  LYRConversation+HONTerminalConversation.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 7/29/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import "HONMessagingUtilities.h"
#import "LYRConversation+HONTerminalConversation.h"

@implementation LYRConversation (HONTerminalConversation)

- (NSString *)terminalGroup
{
    NSDictionary *metadata = self.metadata;
    NSString *terminalGroup = HONFolderNameMetadataNameKey; [metadata valueForKey:@"terminalGroup"];
    
    if (terminalGroup) {
        return terminalGroup;
    }
    
    return nil;
}

@end
