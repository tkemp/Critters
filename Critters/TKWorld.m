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
    NSMutableArray * _curGrid;
    int cols_;
    int rows_;
    BOOL wrap_;
    NSMutableSet * livingCritters_;
}
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
        _curGrid = [NSMutableArray arrayWithCapacity:cols_ * rows_];
        for (int i = 0; i < cols_ * rows_; i++) {
            [_curGrid addObject:[[TKGridSquare alloc] initWithCoordinates:[self positionFromIndex:i]]];
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
    
    TKGridSquare * um = [self gridSquareAtPosition:(Position){umCol, umRow} inGrid:_curGrid];
    TKGridSquare * ur = [self gridSquareAtPosition:(Position){urCol, urRow} inGrid:_curGrid];
    TKGridSquare * mr = [self gridSquareAtPosition:(Position){mrCol, mrRow} inGrid:_curGrid];
    TKGridSquare * br = [self gridSquareAtPosition:(Position){brCol, brRow} inGrid:_curGrid];
    TKGridSquare * bm = [self gridSquareAtPosition:(Position){bmCol, bmRow} inGrid:_curGrid];
    TKGridSquare * bl = [self gridSquareAtPosition:(Position){blCol, blRow} inGrid:_curGrid];
    TKGridSquare * ml = [self gridSquareAtPosition:(Position){mlCol, mlRow} inGrid:_curGrid];
    TKGridSquare * ul = [self gridSquareAtPosition:(Position){ulCol, ulRow} inGrid:_curGrid];
    TKGridSquare * local = [self gridSquareAtPosition:(Position){col, row} inGrid:_curGrid];
    
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
    return [self gridSquareAtIndex:index inGrid:_curGrid];
}

/** Main evaluation function, run once each tick of the simulation clock
 
 Copies the current grid to a temporary grid, processes into that grid, then copies the temp grid to the main grid. Then iterates through each critter and updates their internal position reference to match the grid.
 
 */
- (void) evaluate
{
    NSMutableArray * nextGrid = [NSMutableArray arrayWithCapacity:[_curGrid count]];
    for (int i = 0; i < cols_ * rows_; i++) {
        [nextGrid addObject:[[TKGridSquare alloc] initWithCoordinates:[self positionFromIndex:i]]];
    }
    
    NSMutableSet * newborns = [[NSMutableSet alloc] initWithCapacity:cols_ * rows_];
    
    for (TKCritter * critter in [self livingCritters]) {
        [critter incrementAge];
        TKCritterAction * nextMove = [critter getNextAction:[self localEnvironment:[critter position]]];
        Direction dir = [nextMove direction];
        Position newPos = [self positionForDirection:dir fromPos:[critter position]];
        switch ([nextMove action]) {
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
            default:
                break;
        }
        [self moveCritter:critter fromPosition:[critter position] toPosition:newPos toGrid:nextGrid];
    }
    
    _curGrid = nextGrid;
    [self updateCritters:newborns];
}

#pragma mark Critter interactions
- (void) resolveFightBetween:(TKCritter *) blue and:(TKCritter *) red
{
    if (red.age > blue.age)
        [red die];
    else if (blue.age > red.age)
        [blue die];
}

- (TKCritter *) resolveMatingBetween:(TKCritter *) piglet and:(TKCritter *) monkey
{
    TKCritter * result;
    
    BOOL upForIt = piglet.isReadyToMate && monkey.isReadyToMate;
    BOOL inSameSqure = matchPositions(piglet.position, monkey.position);
    BOOL enoughRoom = [[[self gridSquareAtPosition:piglet.position inGrid:_curGrid] critters] count] < OVERCROWDING_LIMIT;
    
    if (upForIt && inSameSqure && enoughRoom) {
        Gender itsA = rand() % 2;
        result = [self newCritterWithSex:itsA name:[NSString stringWithFormat:@"%@+%@", piglet.name, piglet.target.name]];
        [result setPosition:[piglet position]];
    } else
        result = nil;
    
    return result;
}

#pragma mark Utility methods - used for initial population seed only
- (TKCritter *) makeCritterAtPos:(Position)pos ofSex:(Gender)sex
{
    return [self makeCritterAtPos:pos ofSex:sex inGrid:_curGrid];
}

- (TKCritter *) makeCritterAtPos:(Position) pos ofSex:(Gender)sex inGrid:(NSArray *) theGrid;
{
    TKCritter * critter = [[TKCritter alloc] initWithSex:sex world:self];
    
    [critter setPosition:pos];
    TKGridSquare * home = [self gridSquareAtPosition:pos inGrid:theGrid];
    [home addCritter:critter];
    [self addCritterToList:critter];
    
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

- (void) updateCritters:(NSSet *) newCritters
{
    int bornThisTurn = 0;
    int diedThisTurn = 0;
    
    NSMutableSet * crittersToRemove = [[NSMutableSet alloc] initWithCapacity:10];
    for (TKGridSquare * square in _curGrid) {
        for (TKCritter * critter in [square critters]) {
            [critter setPosition:[square coordinates]];
            if ( ! [critter isAlive]) {
                [crittersToRemove addObject:critter];
                NSLog(@"Removing dead critter %@", critter);
            }
        }
    }
    for (TKCritter * newCritter in newCritters) {
        TKGridSquare * targetSquare = [self gridSquareAtPosition:[newCritter position] inGrid:_curGrid];
        [targetSquare addCritter:newCritter];
        [self addCritterToList:newCritter];
        bornThisTurn++;
    }
    for (TKCritter * deadCritter in crittersToRemove) {
        [self removeCritterFromList:deadCritter];
        [livingCritters_ removeObject:deadCritter];
        [[self gridSquareAtPosition:[deadCritter position] inGrid:_curGrid] removeCritter:deadCritter];
        diedThisTurn++;
    }
    
    NSLog(@"Born: %d died: %d", bornThisTurn, diedThisTurn);
}

- (void) addCritterToList:(TKCritter *) critter
{
    [self willChangeValueForKey:@"critterCountLabel"];
    [livingCritters_ addObject:critter];
    [self didChangeValueForKey:@"critterCountLabel"];
}

- (void) removeCritterFromList:(TKCritter *) deadCritter
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

#pragma mark Manual property acccessors
- (NSString  *) critterCountLabel
{
    return [NSString stringWithFormat:@"%ld", [livingCritters_ count]];
}

@end
