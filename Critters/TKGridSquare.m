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
    NSMutableSet * critters_;
    NSMutableSet * resources_;
}
@synthesize critters = critters_;
@synthesize resources = resources_;
@synthesize coordinates;

- (id)initWithCoordinates:(Position) coords
{
    self = [super init];
    if (self) {
        critters_ = [NSMutableSet setWithCapacity:10];
        resources_ = [NSMutableSet setWithCapacity:10];
        coordinates = coords;
    }
    return self;
}

- (void) addCritter:(TKCritter *) critter
{
    [critters_ addObject:critter];
}

- (void) removeCritter:(TKCritter *) critter
{
    [critters_ removeObject:critter];
}

- (void) addResource:(TKResource *) resource
{
    [resources_ addObject:resource];
}

- (void) removeResource:(TKResource *) resource
{
    [resources_ removeObject:resource];
}

@end
