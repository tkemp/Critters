//
//  TKGridSquare.m
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKGridSquare.h"

@implementation TKGridSquare
{
    NSMutableSet * contents_;
}
@synthesize critters = contents_;

- (id)init
{
    self = [super init];
    if (self) {
        contents_ = [NSMutableSet setWithCapacity:10];
    }
    return self;
}

- (void) addCritter:(TKCritter *) critter
{
    [contents_ addObject:critter];
}

- (void) removeCritter:(TKCritter *) critter
{
    [contents_ removeObject:critter];
}

@end
