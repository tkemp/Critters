//
//  TKCritter.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class TKWorld;

@interface TKCritter : NSObject

@property(readonly) float strength;
@property(readonly) float health;
@property(readonly) int age;
@property(readonly) BOOL sex;
@property BOOL isAlive;
@property(readonly) BOOL needsToEat;
@property Position position;

- (id) initWithSex:(BOOL) gender world:(TKWorld *) homeWorld;

- (Action) getNextAction:(NSArray *) localEnvironment;
- (Direction) getMovementDirection;
- (void) incrementAge;
- (void) incrementHealth;
- (void) decrementHealth;
- (void) incrementStrength;
- (void) decrementStrength;
- (void) die;


@end
