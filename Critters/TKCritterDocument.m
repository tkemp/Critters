//
//  TKCritterDocument.m
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKCritterDocument.h"

@implementation TKCritterDocument
{
    TKWorld * world_;
    TKCritterWindowController * _windowController;
}
@synthesize world = world_;
@synthesize cols;
@synthesize rows;

- (id)init
{
    self = [super init];
    if (self) {
        cols = 32;
        rows = 32;
        world_ = [[TKWorld alloc] initWithCols:self.cols rows:self.rows wrap:YES];
    }
    return self;
}

#pragma mark Model controller stuff
- (void) evaluate
{
    [[self world] evaluate];
}

#pragma mark Debug & development

/** Seed a random population of critters into the world.
 
 Uses a mod 4 random number generator to assign critters to cells and determine critter's sex.
 
 */
- (void) makeRandomPopulation
{
    // Eight critters in random places
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:FEMALE] setName:@"Alice"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:MALE] setName:@"Bob"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:FEMALE] setName:@"Carol"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:MALE] setName:@"Dave"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:FEMALE] setName:@"Ellen"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:MALE] setName:@"Frank"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:FEMALE] setName:@"Georgina"];
    [[world_ makeCritterAtPos:randomPosition(self.cols, self.rows) ofSex:MALE] setName:@"Henry"];
    
    // Random resources
    for (int i = 0; i < self.cols * self.rows; i++) {
        if (rand() % 32 == 0) {
            TKResource * newRes = [[TKResource alloc] init];
            [newRes setType:Food];
            [newRes setQuantity:MAX_RESOURCE_QUANTITY];
            TKGridSquare * square = [world_.gridSquares objectAtIndex:i];
            [square addResource:newRes];
        }
    }
    
    for (TKCritter * critter in [world_ livingCritters]) {
        [critter setDelegate:[TKBasicCritterBrain sharedInstance]];
    }
}

- (TKGridSquare *) gridSquareAtPosition:(Position)pos
{
    return [self.world gridSquareAtPosition:pos inGrid:self.world.gridSquares];
}

- (TKCritter *) critterWithID:(NSString *)critterID
{
    return [world_ critterWithID:critterID];
}

#pragma mark NSDocument stuff

- (void)makeWindowControllers
{
    TKCritterWindowController * controller = [[TKCritterWindowController alloc] init];
    [self addWindowController:controller];
    _windowController = [[self windowControllers] objectAtIndex:0];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return YES;
}

@end
