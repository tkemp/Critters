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

- (id) initWithCols:(int) cols rows:(int) rows wrap:(BOOL) wrapWorld;

#pragma mark Model methods
- (NSArray *) neighboursAtCol:(int) col row:(int) row;
- (TKGridSquare *) gridSquareAtCol:(int) col row:(int) row;
- (TKGridSquare *) gridSquareAtCol:(int)col row:(int)row inGrid:(NSArray *) theGrid;
- (void) evaluate;

#pragma mark Utility methods
- (void) moveCritter:(TKCritter *) critter fromPos:(Position) fromPos toPos:(Position) toPos fromGrid:(NSMutableArray *) fromGrid toGrid:(NSMutableArray *) toGrid;
- (Position) positionForDirection:(Direction) direction fromCol:(int) col fromRow:(int) row;
- (int) indexFromCol:(int) col row:(int) row;
- (int) colFromIndex:(int) index;
- (int) rowFromIndex:(int) index;

@end
