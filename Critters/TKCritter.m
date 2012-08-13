//
//  TKCritter.m
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKCritter.h"
#import "TKWorld.h"

@implementation TKCritter
{
    CFUUIDRef uniqueID_;
    float strength_;
    float health_;
    int age_;
    Gender sex_;
    BOOL isReadyToMate_;
    BOOL isAlive_;
    Position position_;
    TKWorld * _world; // Back reference to world
    
    Direction _nextDirection;
}
@synthesize name;
@synthesize strength = strength_;
@synthesize health = health_;
@synthesize age = age_;
@synthesize sex = sex_;
@synthesize isReadyToMate = isReadyToMate_;
@synthesize isAlive = isAlive_;
@synthesize position = position_;
@synthesize target;

- (id)initWithSex:(Gender) gender world:(TKWorld *) homeWorld
{
    self = [super init];
    if (self) {
        _world = homeWorld;
        strength_ = 1.0;
        health_ = 1.0;
        age_ = 0;
        sex_ = gender;
        isAlive_ = YES;
        target = nil;
        uniqueID_ = CFUUIDCreate(kCFAllocatorDefault);
    }
    return self;
}

- (NSString *) uniqueID
{
    return CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uniqueID_));
}

#pragma mark This critter's state

- (TKCritterAction *) getNextAction:(NSArray *)localEnvironment
{
    TKCritterAction * result = [[TKCritterAction alloc] initWithDirection:Directions[DirNone] action:Nothing];
    
    TKGridSquare * ourSquare = [localEnvironment objectAtIndex:DirNone];
    isReadyToMate_ = (age_ > 4 && health_ >= MAX_HEALTH / 1.3 && strength_ >= MAX_STRENGTH / 1.3); // Need to be pretty healthy to mate
    BOOL wantsToFight = (sex_ == MALE && age_ > 4 && health_ >= MAX_HEALTH / 2 && strength_ >= MAX_STRENGTH / 2);
    BOOL needsToEat = (health_ <= 0.4);
    
    ///TODO: Collapse all this into one run through the grid and neighbours: pre-fill nearest threat and nearest mate, then decide what action to take.
    // If we have to eat (we're dying) then make it a priorty.
    if (needsToEat) {
        Direction nearestFood = Directions[DirNone];
        BOOL foundFood = NO;
        // First check our grid square
        for (TKResource * resource in [ourSquare resources]) {
            if (resource.type == Food) {
                foundFood = YES;
                break;
            }
        }
        // Then check the immediate vicinity
        int relativeDirection = 0;
        for (TKGridSquare * square in localEnvironment) {
            if (foundFood)
                break;
            for (TKResource * resource in [square resources]) {
                if (resource.type == Food) {
                    nearestFood = Directions[relativeDirection];
                    foundFood = YES;
                    break;
                }
            }
            
            relativeDirection++;
        }
        if (foundFood) {
            result.direction = nearestFood;
            if (matchDirections(nearestFood, Directions[DirNone])) {
                result.action = Eat;
            } else  {
                result.action = Move;
            }
            NSString * msg = [NSString stringWithFormat:@"%@ %d,%d Found food dir:%d,%d\n", self.name, self.position.col, self.position.row, nearestFood.dCol, nearestFood.dRow];
            [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:msg];

        } else {
            result.direction = Directions[randomDirection()];
            result.action = Move;
        }
    } else if (isReadyToMate_) {
        Direction nearestMate = Directions[DirNone];
        BOOL foundMate = NO;
        // First check our grid square
        for (TKCritter * critter in [ourSquare critters]) {
            if ([critter sex] != [self sex]) {
                foundMate = YES;
                [self setTarget:critter];
                break;
            }
        }
        // Then check the immediate vicinity
        int relativeDirection = 0;
        for (TKGridSquare * square in localEnvironment) {
            if (foundMate)
                break;
            for (TKCritter * neighbour in [square critters]) {
                if ([neighbour sex] != [self sex] && [neighbour isReadyToMate]) {
                    nearestMate = Directions[relativeDirection];
                    foundMate = YES;
                    [self setTarget:neighbour];
                    break;
                }
            }
            
            relativeDirection++;
        }
        if (foundMate) {
            result.direction = nearestMate;
            if (matchDirections(nearestMate, Directions[DirNone])) {
                result.action = Mate;
            } else  {
                result.action = Move;
            }
        } else { // Go wandering in search of a mate
            result.direction = Directions[randomDirection()];
            result.action = Move;
        }
    } else if (wantsToFight) {
        // Not ready to mate, so if we're male of fighting age let's look for a scrap
        // First check our square...
        BOOL foundTarget = NO;
        for (TKCritter * critter in [ourSquare critters]) {
            if (critter.sex == MALE && critter.age > 4 && critter != self) {
                target = critter;
                result.direction = Directions[DirNone];
                result.action = Fight;
                foundTarget = YES;
                break;
            }
        }
        // Next check the neighbourhood
        int relativeDirection = 0;
        for (TKGridSquare * square in localEnvironment) {
            if (foundTarget)
                break;
            for (TKCritter * neighbour in [square critters]) {
                if ([neighbour sex] == MALE && [neighbour age] > 4 && neighbour != self) {
                    target = neighbour;
                    result.direction = Directions[relativeDirection];
                    result.action = Move;
                    foundTarget = YES;
                    break;
                }
            }
            
            relativeDirection++;
        }
        if ( ! foundTarget) {
            [self setTarget:nil];
            result.direction = Directions[randomDirection()];
            result.action = Move;
        }
    } else {
        // Bugger this, I'm going for a walk.
        [self setTarget:nil];
        result.direction = Directions[randomDirection()];
        result.action = Move;
    }
    
    return result;
}

- (void) incrementAge
{
    age_++;
}

- (void) decrementHealth
{
    health_ = health_ - 0.1;
    if (health_ <= 0.0)
        [self die];
}

- (void) resetStrength
{
    strength_ = MAX_STRENGTH;
}

- (void) increaseHealthBy:(float) vitality
{
    vitality = MAX(vitality, MIN_HEALTH_INCREMENT);
    health_ = MIN(MAX_HEALTH, health_ + vitality);
}

- (void) increaseStrengthBy:(float) fortitude
{
    fortitude = MAX(fortitude, MIN_STRENGTH_INCREMENT);
    strength_ = MIN(MAX_STRENGTH, strength_ + fortitude);
}

- (void) reduceHealthBy:(float) damage
{
    damage = MAX(damage, MIN_HEALTH_INCREMENT);
    health_ = MAX(0, health_ - damage);
    if (health_ == 0)
        [self die];
}

- (void) reduceStrengthBy:(float) weariness
{
    weariness = MAX(weariness, MIN_STRENGTH_INCREMENT);
    strength_ = MAX(0, strength_ - weariness);
    if (strength_ == 0)
        [self die];
}

- (void) die
{
    isAlive_ = false;
    strength_ = 0.0;
    health_ = 0.0;
}

#pragma mark Other critters

- (NSString *) description
{
    NSString * strSex = sex_ == MALE ? @"Male" : @"Female";
    return [NSString stringWithFormat:@"%@ hlt:%f str:%f age:%d sex:%@ alv:%d pos:%d,%d",self.name, health_, strength_, age_, strSex, isAlive_, position_.col, position_.row];
}


@end
