//
//  TKCritter.m
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKCritter.h"

@implementation TKCritter
{
    float strength_;
    float health_;
    int age_;
    BOOL sex_;
    BOOL isAlive_;
    Position pos_;
}
@synthesize strength = strength_;
@synthesize health = health_;
@synthesize age = age_;
@synthesize sex = sex_;
@synthesize isAlive = isAlive_;
@synthesize pos = pos_;

- (id)initWithSex:(BOOL) gender
{
    self = [super init];
    if (self) {
        strength_ = 1.0;
        health_ = 1.0;
        age_ = 0;
        sex_ = gender;
    }
    return self;
}

- (Action) getNextAction:(NSArray *)localEnvironment
{
    ///TODO: Ask the brain to tell us what to do. Long way off!
    return Move;
}

- (Direction) getMovementDirection
{
    ///TODO: Ask the brain to give us a direction
    return NorthEast;
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

- (NSString *) description
{
    return [NSString stringWithFormat:@"hlt:%f str:%f age:%d sex:%d alv:%d",health_, strength_, age_, sex_, isAlive_];
}


@end
