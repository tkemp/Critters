//
//  TKCritter.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#import "TKCritterAction.h"

@class TKWorld;

@interface TKCritter : NSObject

@property(strong) NSString * name;
@property(readonly) float strength;
@property(readonly) float health;
@property(readonly) int age;
@property(readonly) Gender sex;
@property(readonly) BOOL isReadyToMate;
@property BOOL isAlive;
@property Position position;
@property(weak) TKCritter * target;

- (id) initWithSex:(Gender) gender world:(TKWorld *) homeWorld;

#pragma mark This critter's state
- (TKCritterAction *) getNextAction:(NSArray *) localEnvironment;
- (void) incrementAge;
- (void) decrementHealth;
- (void) resetStrength;
- (void) increaseHealthBy:(float) vitality;
- (void) increaseStrengthBy:(float) fortitude;
- (void) reduceHealthBy:(float) damage;
- (void) reduceStrengthBy:(float) weariness;
- (void) die;

#pragma mark Other critters

@end
