//
//  TKBasicCritterBrain.m
//  Critters
//
//  Created by Tim Kemp on 20/08/2012.
//
//

#import "TKBasicCritterBrain.h"

@implementation TKBasicCritterBrain

static TKBasicCritterBrain * sharedBasicCritterBrain;

+ (TKBasicCritterBrain *) sharedInstance
{
    @synchronized (self) {
        if (sharedBasicCritterBrain == nil) {
            (void) [[self alloc] init]; // Why void? http://stackoverflow.com/questions/7914990/xcode-4-warning-expression-result-unused-for-nsurlconnection
        }
    }
    
    return sharedBasicCritterBrain;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedBasicCritterBrain == nil) {
            sharedBasicCritterBrain = [super allocWithZone:zone];
            return sharedBasicCritterBrain;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (TKCritterAction *) actionForEnvironment:(NSArray *) localEnvironment critter:(TKCritter *) critter;
{
    TKCritterAction * result = [[TKCritterAction alloc] initWithDirection:Directions[DirNone] action:Nothing];
    
    TKGridSquare * ourSquare = [localEnvironment objectAtIndex:DirNone];
    BOOL wantsToFight = (critter.sex == MALE && critter.age > 4 && critter.health >= MAX_HEALTH / 2 && critter.strength >= MAX_STRENGTH / 2);
    BOOL needsToEat = (critter.health <= 0.4);
    
    ///TODO: Collapse all this into one run through the grid and neighbours: pre-fill nearest threat and nearest mate, then decide what action to take.
    // If we have to eat (we're dying) then make it a priorty.
    if (needsToEat) {
        NSString * msg = [NSString stringWithFormat:@"%@ %d,%d searching for food\n", critter.name, critter.position.col, critter.position.row];
        [critter.world postConsoleMessage:msg];
        Direction dirToFood = Directions[DirNone];
        BOOL foundFood = NO;
        // First check our grid square
        for (TKResource * resource in [ourSquare resources]) {
            if (resource.type == Food) {
                foundFood = YES;
                msg = [NSString stringWithFormat:@"%@ %d,%d found local food %f at %d,%d\n", critter.name, critter.position.col, critter.position.row, resource.quantity, ourSquare.coordinates.col, ourSquare.coordinates.row];
                [critter.world postConsoleMessage:msg];
                break;
            }
        }
        // Then check the immediate vicinity
        for (TKGridSquare * square in localEnvironment) {
            if (foundFood)
                break;
            for (TKResource * resource in [square resources]) {
                if (resource.type == Food) {
                    dirToFood = [critter.world directionTo:square.coordinates from:critter.position];
                    foundFood = YES;
                    msg = [NSString stringWithFormat:@"%@ %d,%d found neighbourhood food %f at %d,%d\n", critter.name, critter.position.col, critter.position.row, resource.quantity, square.coordinates.col, square.coordinates.row];
                    [critter.world postConsoleMessage:msg];
                    break;
                }
            }
        }
        if (foundFood) {
            result.direction = dirToFood;
            if (matchDirections(dirToFood, Directions[DirNone])) {
                result.action = Eat;
            } else  {
                result.action = Move;
            }
            
            NSString * msg = [NSString stringWithFormat:@"%@ %d,%d Found food dir:%d,%d\n", critter.name, critter.position.col, critter.position.row, dirToFood.dCol, dirToFood.dRow];
            [critter.world postConsoleMessage:msg];
            
        } else {
            result.direction = Directions[randomDirection()];
            result.action = Move;
        }
    } else if (critter.isReadyToMate) {
        [critter.world postConsoleMessage:[NSString stringWithFormat:@"%@ %d,%d Searching for a mate\n", critter.name, critter.position.col, critter.position.row]];
        Direction nearestMate = Directions[DirNone];
        BOOL foundMate = NO;
        // First check our grid square
        for (TKCritter * localCritter in ourSquare.critters) {
            if (localCritter.sex != critter.sex) {
                foundMate = YES;
                [critter setTarget:localCritter];
                break;
            }
        }
        // Then check the immediate vicinity
        for (TKGridSquare * square in localEnvironment) {
            if (foundMate)
                break;
            for (TKCritter * neighbour in [square critters]) {
                if ([neighbour sex] != critter.sex && neighbour.isReadyToMate) {
                    nearestMate =[critter.world directionTo:neighbour.position from:critter.position];
                    foundMate = YES;
                    [critter setTarget:neighbour];
                    break;
                }
            }
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
        // Not ready to mate, so if we're male of fighting age let's look for a scrap and try and kill off the competition
        // First check our square...
        BOOL foundTarget = NO;
        for (TKCritter * localCritter in [ourSquare critters]) {
            if (localCritter.sex == MALE && localCritter.age > 4 && localCritter != critter) {
                [critter setTarget:localCritter];
                result.direction = Directions[DirNone];
                result.action = Fight;
                foundTarget = YES;
                break;
            }
        }
        // Next check the neighbourhood
        for (TKGridSquare * square in localEnvironment) {
            if (foundTarget)
                break;
            for (TKCritter * neighbour in [square critters]) {
                if (neighbour.sex == MALE && neighbour.age > 4 && neighbour != critter) {
                    [critter setTarget:neighbour];
                    result.direction = [critter.world directionTo:neighbour.position from:critter.position];
                    result.action = Move;
                    foundTarget = YES;
                    break;
                }
            }
        }
        if ( ! foundTarget) {
            [critter setTarget:nil];
            result.direction = Directions[randomDirection()];
            result.action = Move;
        }
    } else {
        // Bugger this, I'm going for a walk.
        [critter setTarget:nil];
        result.direction = Directions[randomDirection()];
        result.action = Move;
    }
    
    return result;
}


@end
