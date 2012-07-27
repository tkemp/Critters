//
//  TKWorld.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKGridSquare.h"
#import "TKCritter.h"

@interface TKWorld : NSObject

@property int cols;
@property int rows;
@property BOOL wrap;
@property(strong) NSMutableSet * livingCritters;

- (id) initWithCols:(int) cols rows:(int) rows wrap:(BOOL) wrapWorld;

#pragma mark Model methods
- (NSArray *) neighboursAtPosition:(Position) pos;
- (TKGridSquare *) gridSquareAtPosition:(Position) pos;
- (TKGridSquare *) gridSquareAtCol:(int) col row:(int) row;
- (TKGridSquare *) gridSquareAtCol:(int)col row:(int)row inGrid:(NSArray *) theGrid;
- (TKGridSquare *) gridSquareAtIndex:(int) index;
- (void) evaluate;

#pragma mark Utility methods
- (TKCritter *) makeCritterAtPos:(Position) pos ofSex:(BOOL) sex;
- (void) moveCritter:(TKCritter *) critter fromPosition:(Position) fromPos toPosition:(Position) toPos fromGrid:(NSMutableArray *) fromGrid toGrid:(NSMutableArray *) toGrid;
- (Position) positionForDirection:(Direction) direction fromPos:(Position) startPos;
- (Position) positionFromIndex:(int) index;
- (int) indexFromCol:(int) col row:(int) row;
- (int) colFromIndex:(int) index;
- (int) rowFromIndex:(int) index;

@end
