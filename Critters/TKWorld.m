//
//  TKWorld.m
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKWorld.h"

@implementation TKWorld
{
    NSMutableArray * gridSquares_;
    int cols_;
    int rows_;
    BOOL wrap_;
    NSMutableSet * livingCritters_;
}
@synthesize gridSquares = gridSquares_;
@synthesize cols = cols_;
@synthesize rows = rows_;
@synthesize wrap = wrap_;
@synthesize livingCritters = livingCritters_;

- (id) initWithCols:(int)cols rows:(int)rows wrap:(BOOL)wrapWorld
{
    self = [super init];
    if (self) {
        cols_ = cols;
        rows_ = rows;
        wrap_ = wrapWorld;
        gridSquares_ = [NSMutableArray arrayWithCapacity:cols_ * rows_];
        for (int i = 0; i < cols_ * rows_; i++) {
            [gridSquares_ addObject:[[TKGridSquare alloc] initWithCoordinates:[self positionFromIndex:i]]];
        }
        livingCritters_ = [NSMutableSet setWithCapacity:cols_ * rows_];
    }
    
    return self;
}

#pragma mark Model methods
- (NSArray *) localEnvironment:(Position) pos
{
    NSArray * result;
    
    int col = pos.col;
    int row = pos.row;
    
    // Get all the neighbours of the cell. Start at top left and work around.
    int umCol = col;     int umRow = row - 1;
    int urCol = col + 1; int urRow = row - 1;
    int mrCol = col + 1; int mrRow = row;
    int brCol = col + 1; int brRow = row + 1;
    int bmCol = col;     int bmRow = row + 1;
    int blCol = col - 1; int blRow = row + 1;
    int mlCol = col - 1; int mlRow = row;
    int ulCol = col - 1; int ulRow = row - 1;
    
    if (wrap_) {
        urCol = urCol % cols_;
        mrCol = mrCol % cols_;
        brCol = brCol % cols_;
        blCol = blCol % cols_;
        mlCol = mlCol % cols_;
        ulCol = ulCol % cols_;
        
        // Fix for broken mod operator (it returns -1 instead of 15 for -1 % 16)
        urCol < 0 ? ulCol += cols_ : ulCol;
        mrCol < 0 ? mrCol += cols_ : mrCol;
        brCol < 0 ? brCol += cols_ : brCol;
        blCol < 0 ? blCol += cols_ : blCol;
        mlCol < 0 ? mlCol += cols_ : mlCol;
        ulCol < 0 ? ulCol += cols_ : ulCol;
        
        ulRow = ulRow % rows_;
        umRow = umRow % rows_;
        urRow = urRow % rows_;
        brRow = brRow % rows_;
        bmRow = bmRow % rows_;
        blRow = blRow % rows_;
        
        // Fix for broken mod operator
        umRow < 0 ? umRow += rows_ : umRow;
        urRow < 0 ? urRow += rows_ : urRow;
        brRow < 0 ? brRow += rows_ : brRow;
        bmRow < 0 ? bmRow += rows_ : bmRow;
        blRow < 0 ? blRow += rows_ : blRow;
        ulRow < 0 ? ulRow += rows_ : ulRow;
    }
    
    TKGridSquare * um = [self gridSquareAtPosition:(Position){umCol, umRow} inGrid:gridSquares_];
    TKGridSquare * ur = [self gridSquareAtPosition:(Position){urCol, urRow} inGrid:gridSquares_];
    TKGridSquare * mr = [self gridSquareAtPosition:(Position){mrCol, mrRow} inGrid:gridSquares_];
    TKGridSquare * br = [self gridSquareAtPosition:(Position){brCol, brRow} inGrid:gridSquares_];
    TKGridSquare * bm = [self gridSquareAtPosition:(Position){bmCol, bmRow} inGrid:gridSquares_];
    TKGridSquare * bl = [self gridSquareAtPosition:(Position){blCol, blRow} inGrid:gridSquares_];
    TKGridSquare * ml = [self gridSquareAtPosition:(Position){mlCol, mlRow} inGrid:gridSquares_];
    TKGridSquare * ul = [self gridSquareAtPosition:(Position){ulCol, ulRow} inGrid:gridSquares_];
    TKGridSquare * local = [self gridSquareAtPosition:(Position){col, row} inGrid:gridSquares_];
    
    result = [[NSArray alloc] initWithObjects:um, ur, mr, br, bm, bl, ml, ul, local, nil];
    
    return result;
}

- (TKGridSquare *) gridSquareAtPosition:(Position) pos inGrid:theGrid
{
    return [theGrid objectAtIndex:[self indexFromCol:pos.col row:pos.row]];
}

- (TKGridSquare *) gridSquareAtIndex:(int)index inGrid:theGrid
{
    return [theGrid objectAtIndex:index];
}

- (TKGridSquare *) gridSquareAtIndex:(int)index
{
    return [self gridSquareAtIndex:index inGrid:gridSquares_];
}

#pragma mark Main evaluation loop & state management

/** Main evaluation function, run once each tick of the simulation clock
 
 Copies the current grid to a temporary grid, processes into that grid, then copies the temp grid to the main grid. Then iterates through each critter and updates their internal position reference to match the grid.
 
 */
- (void) evaluate
{
    NSMutableArray * nextGrid = [NSMutableArray arrayWithCapacity:[gridSquares_ count]];
    for (int i = 0; i < cols_ * rows_; i++) {
        TKGridSquare * newSquare = [[TKGridSquare alloc] initWithCoordinates:[self positionFromIndex:i]];
        [newSquare setResources:[[gridSquares_ objectAtIndex:i] resources]];
        [nextGrid addObject:newSquare];
    }
    
    NSMutableSet * newborns = [[NSMutableSet alloc] initWithCapacity:cols_ * rows_];
    
    for (TKCritter * critter in [self livingCritters]) {
        [critter incrementAge];
        
        TKCritterAction * nextMove = [critter getNextAction:[self localEnvironment:[critter position]]];
        Direction dir = [nextMove direction];
        Position newPos = [self positionForDirection:dir fromPos:[critter position]];
        switch ([nextMove action]) {
            case Move:
                [critter reduceHealthBy:0.1];
                break;
            case Mate:
            {
                TKCritter * newborn = [self resolveMatingBetween:critter and:critter.target];
                if (newborn != nil)
                    [newborns addObject:newborn];
            }
                break;
            case Fight:
                [self resolveFightBetween:critter and:critter.target];
                break;
            case Eat:
                [self resolveEating:critter];
                break;
            default:
                break;
        }
        [self moveCritter:critter fromPosition:[critter position] toPosition:newPos toGrid:nextGrid];
    }
    
    gridSquares_ = nextGrid;
    [self updateCritters:newborns];
}

/** Remove dead critters from grid squares, add newborns to their grid squares and shift moved critters to the correct grid square.
 
 @param: newCritters: set of newborn critters to add.
 
 */
- (void) updateCritters:(NSSet *) newCritters
{
    NSMutableSet * crittersToRemove = [[NSMutableSet alloc] initWithCapacity:rows_ * cols_]; // Conservative one per square
    // First find all the dead critters, but do it while moving the living ones around so we're not iterating twice.
    for (TKGridSquare * square in gridSquares_) {
        for (TKCritter * critter in [square critters]) {
            [critter setPosition:[square coordinates]];
            if ( ! [critter isAlive]) {
                [crittersToRemove addObject:critter];
            }
        }
    }
    // Then process the newborns
    for (TKCritter * newCritter in newCritters) {
        TKGridSquare * targetSquare = [self gridSquareAtPosition:[newCritter position] inGrid:gridSquares_];
        [targetSquare addCritter:newCritter];
        [self addCritterToLivingList:newCritter];
    }
    // Then remove the dead critters
    for (TKCritter * deadCritter in crittersToRemove) {
        [self removeCritterFromLivingList:deadCritter];
        [livingCritters_ removeObject:deadCritter];
        [[self gridSquareAtPosition:[deadCritter position] inGrid:gridSquares_] removeCritter:deadCritter];
        [self postWorldEventNotification:CritterDied payload:deadCritter.uniqueID];
    }
}

#pragma mark Critter interaction & management
- (void) resolveFightBetween:(TKCritter *) blue and:(TKCritter *) red
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:[NSString stringWithFormat:@"resolveFightBetween %@ %f %f and %@ %f %f\n", blue.name, blue.health, blue.strength, red.name, red.health, red.strength]];

    // A bruising battle between equal combatants
    if (red.strength == blue.strength && red.health == blue.health) {
        [red reduceStrengthBy:red.strength / 2];
        [blue reduceStrengthBy:blue.strength / 2];
        [red reduceHealthBy:red.health / 1.5];
        [blue reduceHealthBy:blue.health / 1.5];
    } else {
        [red reduceHealthBy:blue.strength];
        [blue reduceHealthBy:red.strength];
        [red reduceStrengthBy:red.strength / 1.5];
        [blue reduceStrengthBy:blue.strength / 1.5];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:[NSString stringWithFormat:@"After the fight %@ %f %f, %@ %f %f\n", blue.name, blue.health, blue.strength, red.name, red.health, red.strength]];

}

- (TKCritter *) resolveMatingBetween:(TKCritter *) piglet and:(TKCritter *) monkey
{
    TKCritter * result;
    
    BOOL upForIt = piglet.isReadyToMate && monkey.isReadyToMate;
    BOOL inSameSquare = matchPositions(piglet.position, monkey.position);
    BOOL enoughRoom = [[[self gridSquareAtPosition:piglet.position inGrid:gridSquares_] critters] count] < OVERCROWDING_LIMIT;
    
    if (upForIt && inSameSquare && enoughRoom) {
        Gender itsA = rand() % 2;
        result = [self newCritterWithSex:itsA name:[NSString stringWithFormat:@"%@+%@", piglet.name, piglet.target.name]];
        [result setPosition:[piglet position]];
    } else
        result = nil;
    
    return result;
}

- (void) resolveEating:(TKCritter *) nibbler
{
    TKGridSquare * square = [self gridSquareAtPosition:nibbler.position inGrid:gridSquares_];
    // Try and optimally use resources; take only what we need, but as much as we can.
    TKResource * bestResource;
    float requiredFood = MAX_HEALTH - nibbler.health;
    for (TKResource * resource in square.resources) {
        // Is there actually food here.
        if (resource.type == Food && resource.quantity > MIN_RESOURCE_QUANTITY) {
            // If so, then have we already got a candidate for the optimal resource? Set it to this, if not
            if (bestResource == nil)
                bestResource = resource;
            // If so, then is this resource better than our previous best?
            else if (resource.quantity <= requiredFood && resource.quantity > bestResource.quantity) {
                bestResource = resource;
            } else if (resource.quantity > requiredFood && resource.quantity <= bestResource.quantity) {
                bestResource = resource;
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:[NSString stringWithFormat:@"Error! trying to eat nothing\n"]];

        }
    }
    // Shouldn't be nil ever! We should only try and eat when there's food, but you never know
    if (bestResource != nil) {
        float qty = MIN(bestResource.quantity, requiredFood);
        NSString * msg = [NSString stringWithFormat:@"%@ needs %f, eating %f of %f at %d,%d\n", nibbler.name, requiredFood, qty, bestResource.quantity, nibbler.position.col, nibbler.position.row];
        [nibbler increaseHealthBy:qty];
        [bestResource setQuantity:bestResource.quantity - qty];
        [nibbler resetStrength];
        [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:msg];
        if (bestResource.quantity == 0) {
            [self postWorldEventNotification:ResourceDepleted payload:bestResource.uniqueID];
        }

    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NTFY_CONSOLE_LOG object:@"Tried to eat food when none was there. Error in resolveEating?\n"];
    }
}

- (TKCritter *) critterWithID:(NSString *) idToFind
{
    TKCritter * result = nil;
    
    for (TKCritter * critter in livingCritters_) {
        if ([critter.uniqueID isEqualToString:idToFind]) {
            result = critter;
            break;
        }
    }
    
    return result;
}

#pragma mark Utility methods - used for initial population seed only
- (TKCritter *) makeCritterAtPos:(Position)pos ofSex:(Gender)sex
{
    return [self makeCritterAtPos:pos ofSex:sex inGrid:gridSquares_];
}

- (TKCritter *) makeCritterAtPos:(Position) pos ofSex:(Gender)sex inGrid:(NSArray *) theGrid;
{
    TKCritter * critter = [[TKCritter alloc] initWithSex:sex world:self];
    
    [critter setPosition:pos];
    TKGridSquare * home = [self gridSquareAtPosition:pos inGrid:theGrid];
    [home addCritter:critter];
    [self addCritterToLivingList:critter];
    
    return critter;
}

#pragma mark General utility methods
- (TKCritter *) newCritterWithSex:(Gender) sex name:(NSString *) name
{
    TKCritter * result = [[TKCritter alloc] initWithSex:sex world:self];
    
    [result setName:name];
    
    return result;
}

- (void) moveCritter:(TKCritter *) critter fromPosition:(Position) fromPos toPosition:(Position) toPos toGrid:(NSMutableArray *) toGrid
{
    TKGridSquare * dest = [self gridSquareAtPosition:toPos inGrid:toGrid];
    [dest addCritter:critter];
}

- (void) addCritterToLivingList:(TKCritter *) critter
{
    [self willChangeValueForKey:@"critterCountLabel"];
    [livingCritters_ addObject:critter];
    [self didChangeValueForKey:@"critterCountLabel"];
}

- (void) removeCritterFromLivingList:(TKCritter *) deadCritter
{
    [self willChangeValueForKey:@"critterCountLabel"];
    [livingCritters_ removeObject:deadCritter];
    [self didChangeValueForKey:@"critterCountLabel"];
}

- (Position) positionForDirection:(Direction) direction fromPos:(Position) startPos;
{
    Position result;
    
    result.col = (direction.dCol + startPos.col) % self.cols;
    result.row = (direction.dRow + startPos.row) % self.rows;
    
    // Broken mod
    if (result.col < 0)
        result.col += cols_;
    if (result.row < 0)
        result.row += rows_;
    
    return result;
}

- (Position) positionFromIndex:(int) index
{
    Position result;
    
    result.col = [self colFromIndex:index];
    result.row = [self rowFromIndex:index];
    
    return result;
}

- (int) indexFromCol:(int)col row:(int)row
{
    return (row * cols_) + col;
}

- (int) colFromIndex:(int) index
{
    return index % cols_;
}

- (int) rowFromIndex:(int) index
{
    return index / cols_;
}

/** Send an NSNotification about a significant world event. Used to maintain an asynchronous, loose coupling between the UI's representation of world state and the world model. Main purpose is to notify the UI of dead critters and depleted resources, since simple additions and changes are handled by the tick-driven update. This is not intended to become a generalised messaging bus between different subsystems, rather to keep a clean MVC approach with a rapidly changing UI and model.

 The only consumer of these notifications (so far) is the TKCritterWindowController class which has callbacks associated with each event type.
 
 @param: event Is the WorldEvent enum for the particular state change that happened. Defined in constants.h
 @param: payload Usually an NSString identifying the ID of the depleted resource or dead critter, so that the UI can remove its representation from the screen.
 
 */
- (void) postWorldEventNotification:(WorldEvent) event payload:(NSObject *) payload
{
    NSString * eventName = nil;
    
    switch (event) {
        case CritterDied:
            eventName = NTFY_CRITTER_DIED;
            break;
        case ResourceDepleted:
            eventName = NTFY_RESOURCE_DEPLETED;
            break;
        default:
            break;
    }
    
    if (eventName != nil && payload != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:payload];
    }
}

#pragma mark Manual property acccessors
- (NSString  *) critterCountLabel
{
    return [NSString stringWithFormat:@"%ld", [livingCritters_ count]];
}

@end
