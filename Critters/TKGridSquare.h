//
//  TKGridSquare.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKCritter.h"
#import "constants.h"

@interface TKGridSquare : NSObject
@property(readonly) NSSet * critters;
@property(readonly) Position coordinates;

- (id)initWithCoordinates:(Position) coords;

- (void) addCritter:(TKCritter *) critter;
- (void) removeCritter:(TKCritter *) critter;

@end
