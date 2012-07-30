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
    }
    return self;
}

#pragma mark This critter's state

- (TKCritterAction *) getNextAction:(NSArray *)localEnvironment
{
    TKCritterAction * result = [[TKCritterAction alloc] initWithDirection:Directions[None] action:Nothing];
    
    TKGridSquare * ourSquare = [localEnvironment objectAtIndex:None];
    isReadyToMate_ = (age_ % 4 == 0 && age_ > 0);
    
    // Breed once every 4 years
    if (isReadyToMate_) {
        NSLog(@"Looking for a shag");
        Direction nearestMate = Directions[None];
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
            if (matchDirections(nearestMate, Directions[None])) {
                result.action = Mate;
            } else  {
                result.action = Move;
            }
        }
    } else if (sex_ == MALE && age_ > 4) {
        NSLog(@"Looking for scrap");
        // Not ready to mate, so if we're male of fighting age let's look for a scrap
        // First check our square...
        BOOL foundTarget = NO;
        for (TKCritter * critter in [ourSquare critters]) {
            if (critter.sex == MALE && critter.age > 4 && critter != self) {
                target = critter;
                result.direction = Directions[None];
                result.action = Fight;
                foundTarget = YES;
                NSLog(@"%@ fighting %@", self.name, target.name);
                break;
            }
        }
        // Next check the neighbourhood
        int relativeDirection = 0;
        for (TKGridSquare * square in localEnvironment) {
            if (foundTarget)
                break;
            for (TKCritter * neighbour in [square critters]) {
                if ([neighbour sex] == MALE && [neighbour age] > 4) {
                    target = neighbour;
                    result.direction = Directions[relativeDirection];
                    result.action = Move;
                    foundTarget = YES;
                    NSLog(@"Moving to intercept");
                    break;
                }
            }
        }
    } else {
        // Bugger this, I'm going for a walk.
        [self setTarget:nil];
        result.direction = Directions[randomDirection()];
        result.action = Move;
    }
    
    return result;
}

- (BOOL) needsToEat
{
    return (health_ < 1.0 && (health_ < 1.0 || strength_ < 1.0));
}

- (void) incrementAge
{
    age_++;
}

- (void) incrementHealth
{
    health_++;
    health_ = MAX(health_, MAX_HEALTH);
}

- (void) decrementHealth
{
    health_ = health_ - 0.1;
    if (health_ <= 0.0)
        [self die];
}

- (void) incrementStrength
{
    strength_++;
    strength_ = MAX(strength_, MAX_STRENGTH);
}

- (void) decrementStrength
{
    strength_--;
    strength_ = MIN(strength_, 0.0);
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
