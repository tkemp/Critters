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
    NSMutableSet * _livingCritters;
    int cols_;
    int rows_;
    BOOL wrap_;
}
@synthesize cols = cols_;
@synthesize rows = rows_;
@synthesize wrap = wrap_;

- (id) initWithCols:(int)cols rows:(int)rows wrap:(BOOL)wrapWorld
{
    self = [super init];
    if (self) {
        cols_ = cols;
        rows_ = rows;
        wrap_ = wrapWorld;
        _curGrid = [NSMutableArray arrayWithCapacity:cols_ * rows_];
        for (int i = 0; i < cols_ * rows_; i++) {
            [_curGrid addObject:[[TKGridSquare alloc] init]];
        }
        _livingCritters = [NSMutableSet setWithCapacity:cols_ * rows_];
    }
    
    return self;
}

#pragma mark Model methods
- (NSArray *) neighboursAtCol:(int) col row:(int) row
{
    NSArray * result;
    
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
    
    TKGridSquare * um = [self gridSquareAtCol:umCol row:umRow];        
    TKGridSquare * ur = [self gridSquareAtCol:urCol row:urRow];    
    TKGridSquare * mr = [self gridSquareAtCol:mrCol row:mrRow];       
    TKGridSquare * br = [self gridSquareAtCol:brCol row:brRow];   
    TKGridSquare * bm = [self gridSquareAtCol:bmCol row:bmRow];       
    TKGridSquare * bl = [self gridSquareAtCol:blCol row:blRow];   
    TKGridSquare * ml = [self gridSquareAtCol:mlCol row:mlRow];
    TKGridSquare * ul = [self gridSquareAtCol:ulCol row:ulRow];       
    
    result = [[NSArray alloc] initWithObjects:um, ur, mr, br, bm, bl, ml, ul, nil];
    
    return result;
}

- (TKGridSquare *) gridSquareAtCol:(int)col row:(int)row
{
    TKGridSquare * result;
    
    result = [self gridSquareAtCol:col row:row inGrid:_curGrid];
    
    return result;
}

- (TKGridSquare *) gridSquareAtCol:(int)col row:(int)row inGrid:(NSArray *)theGrid
{
    TKGridSquare * result;
    
    result = [theGrid objectAtIndex:[self indexFromCol:col row:row]];
    
    return result;
}

- (void) evaluate
{
    NSMutableArray * nextGrid = [NSMutableArray arrayWithArray:_curGrid];
    
    for (TKCritter * critter in _livingCritters) {
        int curCol = [critter pos].col;
        int curRow = [critter pos].row;
        Action act = [critter getNextAction:[self neighboursAtCol:curCol row:curRow]];
        switch (act) {
            case Move: {
                Direction dir = [critter getMovementDirection];
                Position newPos = [self positionForDirection:dir fromCol:curCol fromRow:curRow];
                [self moveCritter:critter fromPos:[critter pos] toPos:newPos fromGrid:nextGrid toGrid:nextGrid];
            }
                break;
                
            default:
                break;
        }
    }
    
    _curGrid = nextGrid;
}

#pragma mark Utility methods
- (void) moveCritter:(TKCritter *) critter fromPos:(Position) fromPos toPos:(Position) toPos fromGrid:(NSMutableArray *) fromGrid toGrid:(NSMutableArray *) toGrid
{
    TKGridSquare * source = [self gridSquareAtCol:fromPos.col row:fromPos.row inGrid:fromGrid];
    TKGridSquare * dest = [self gridSquareAtCol:toPos.col row:toPos.row inGrid:toGrid];
    [[source contents] removeObject:critter];
    [[dest contents] addObject:critter];
    [critter setPos:toPos];
}

- (Position) positionForDirection:(Direction)direction fromCol:(int)col fromRow:(int)row
{
    Position result;
    int dCol, dRow = 0;
    
    switch (direction) {
        case North:
            dRow = -1;
            break;
        case NorthEast:
            dCol = 1;
            dRow = -1;
            break;
        case East:
            dCol = 1;
            break;
        case SouthEast:
            dCol = 1;
            dRow = 1;
            break;
        case South:
            dRow = 1;
            break;
        case SouthWest:
            dRow = 1;
            dCol = -1;
            break;
        case West:
            dCol = -1;
            break;
        case NorthWest:
            dCol = -1;
            dRow = -1;
            break;
        default:
            break;
    }
    
    result.col = (col + dCol) % cols_;
    result.row = (row + dRow) % rows_;
    
    // Broken mod
    result.col < 0 ? result.col += cols_ : result.col;
    result.row < 0 ? result.row += rows_ : result.row;

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

@end
