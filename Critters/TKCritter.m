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
    BOOL isAlive_;
    Position position_;
    TKWorld * world_; // Back reference to world
    
    Direction _nextDirection;
}
@synthesize name;
@synthesize strength = strength_;
@synthesize health = health_;
@synthesize age = age_;
@synthesize sex = sex_;
@synthesize isAlive = isAlive_;
@synthesize target;
@synthesize delegate;
@synthesize world = world_;

- (id)initWithSex:(Gender) gender world:(TKWorld *) homeWorld
{
    self = [super init];
    if (self) {
        world_ = homeWorld;
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

- (int) col
{
    return self.position.col;
}

- (int) row
{
    return self.position.row;
}

- (void) setPosition:(Position) thePos
{
    [self willChangeValueForKey:@"position"];
    [self willChangeValueForKey:@"col"];
    [self willChangeValueForKey:@"row"];
    position_ = thePos;
    [self didChangeValueForKey:@"position"];
    [self didChangeValueForKey:@"col"];
    [self didChangeValueForKey:@"row"];
}

- (Position) position
{
    return position_;
}

#pragma mark This critter's state

/** This returns the output of the AI routine: the next action the critter will take. Currently this method is a stub with hard-coded rules.
 
 @param: localEnvironment - this is the array of 8 squares around the critter and the square the critter is currently in.
 @return TKCritterAction - representing the direction and action to take next.
 
 */
- (TKCritterAction *) getNextAction:(NSArray *)localEnvironment
{
    if (delegate) {
        return [delegate actionForEnvironment:localEnvironment critter:self];
    } else {
        return [[TKCritterAction alloc] initWithDirection:Directions[DirNone] action:Nothing];
    }
}

- (BOOL) isReadyToMate
{
    return (age_ > 4 && health_ >= MAX_HEALTH / 1.3 && strength_ >= MAX_STRENGTH / 1.3); // Need to be pretty healthy to mate
}

- (void) incrementAge
{
    [self willChangeValueForKey:@"age"];
    age_++;
    [self didChangeValueForKey:@"age"];
}

- (void) decrementHealth
{
    [self willChangeValueForKey:@"health"];
    health_ = health_ - 0.1;
    if (health_ <= 0.0)
        [self die];
    [self didChangeValueForKey:@"health"];
}

- (void) resetStrength
{
    [self willChangeValueForKey:@"strength"];
    strength_ = MAX_STRENGTH;
    [self didChangeValueForKey:@"strength"];
}

- (void) increaseHealthBy:(float) vitality
{
    [self willChangeValueForKey:@"health"];
    vitality = MAX(vitality, MIN_HEALTH_INCREMENT);
    health_ = MIN(MAX_HEALTH, health_ + vitality);
    [self didChangeValueForKey:@"health"];
}

- (void) increaseStrengthBy:(float) fortitude
{
    [self willChangeValueForKey:@"strength"];
    fortitude = MAX(fortitude, MIN_STRENGTH_INCREMENT);
    strength_ = MIN(MAX_STRENGTH, strength_ + fortitude);
    [self didChangeValueForKey:@"strength"];
}

- (void) reduceHealthBy:(float) damage
{
    [self willChangeValueForKey:@"health"];
    damage = MAX(damage, MIN_HEALTH_INCREMENT);
    health_ = MAX(0, health_ - damage);
    if (health_ == 0)
        [self die];
    [self didChangeValueForKey:@"health"];
}

- (void) reduceStrengthBy:(float) weariness
{
    [self willChangeValueForKey:@"strength"];
    weariness = MAX(weariness, MIN_STRENGTH_INCREMENT);
    strength_ = MAX(0, strength_ - weariness);
    if (strength_ == 0)
        [self die];
    [self didChangeValueForKey:@"strength"];
}

- (void) die
{
    if (isAlive_) {
        [world_ postConsoleMessage:[NSString stringWithFormat:@"%@ died at %d,%d\n", self.name, self.position.col, self.position.row]];
        [self willChangeValueForKey:@"health"];
        [self willChangeValueForKey:@"strength"];
        isAlive_ = false;
        strength_ = 0.0;
        health_ = 0.0;
        [self didChangeValueForKey:@"health"];
        [self didChangeValueForKey:@"strength"];
    }
}

#pragma mark Other critters

- (NSString *) description
{
    NSString * strSex = sex_ == MALE ? @"Male" : @"Female";
    return [NSString stringWithFormat:@"%@ hlt:%f str:%f age:%d sex:%@ alv:%d pos:%d,%d",self.name, health_, strength_, age_, strSex, isAlive_, position_.col, position_.row];
}


@end
