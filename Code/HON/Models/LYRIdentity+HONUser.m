//
//  HONUser.m
//  Atlas Messenger
//
//  Created by Daniel Maness on 7/29/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import "LYRIdentity+HONUser.h"

@implementation LYRIdentity (HONUser)

- (BOOL)isAdmin
{
    NSDictionary *metadata = self.metadata;
    NSString *isAdminString = [metadata valueForKey:@"isAdmin"];
    BOOL isAdmin = [isAdminString boolValue];
    
    return isAdmin;
}

@end
