//
//  TKCritterDocument.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TKCritterWindowController.h"
#import "TKWorld.h"
#import "TKGridSquare.h"
#import "TKCritter.h"
#import "TKResource.h"
#import <stdlib.h>

@interface TKCritterDocument : NSDocument

@property(strong) TKWorld * world;
@property int cols;
@property int rows;

- (void) evaluate;
- (void) makeRandomPopulation;

- (TKGridSquare *) gridSquareAtPosition:(Position) pos;
- (TKCritter *) critterWithID:(NSString *) critterID;

@end
