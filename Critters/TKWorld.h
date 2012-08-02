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
#import "TKCritterAction.h"

@interface TKWorld : NSObject

@property(strong, readonly) NSArray * gridSquares;
@property int cols;
@property int rows;
@property BOOL wrap;
@property(strong) NSMutableSet * livingCritters;
@property(strong, readonly) NSString * critterCountLabel;

- (id) initWithCols:(int) cols rows:(int) rows wrap:(BOOL) wrapWorld;

#pragma mark Model methods
- (NSArray *) localEnvironment:(Position) pos;
- (TKGridSquare *) gridSquareAtPosition:(Position) pos inGrid:(NSArray *) theGrid;
- (TKGridSquare *) gridSquareAtIndex:(int) index inGrid:(NSArray *) theGrid;
- (TKGridSquare *) gridSquareAtIndex:(int) index;
- (void) evaluate;

#pragma mark Critter interactions
#pragma mark Utility methods - used for initial population seed only
- (TKCritter *) makeCritterAtPos:(Position) pos ofSex:(Gender) sex;
#pragma mark General utility methods
- (TKCritter *) newCritterWithSex:(Gender) sex name:(NSString *) name;
- (void) moveCritter:(TKCritter *) critter fromPosition:(Position) fromPos toPosition:(Position) toPos toGrid:(NSMutableArray *) toGrid;
- (Position) positionForDirection:(Direction) direction fromPos:(Position) startPos;
- (Position) positionFromIndex:(int) index;
- (int) indexFromCol:(int) col row:(int) row;
- (int) colFromIndex:(int) index;
- (int) rowFromIndex:(int) index;
#pragma mark Manual property accessors

@end
