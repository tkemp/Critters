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

- (id)init
{
    self = [super init];
    if (self) {
        world_ = [[TKWorld alloc] initWithCols:8 rows:8 wrap:YES];
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
//    for (int i = 0; i < [world_ cols] * [world_ rows]; i++) {
//        int val = 1 + rand() % 8;
//        if (val <= 2) {
//            Position pos = [world_ positionFromIndex:i];
//            Gender sex = val == 2 ? MALE : FEMALE;
//            [world_ makeCritterAtPos:pos ofSex:sex];
//        }
//    }

    [[world_ makeCritterAtPos:(Position) {1, 2} ofSex:FEMALE] setName:@"Alice"];
    [[world_ makeCritterAtPos:(Position) {2, 1} ofSex:MALE] setName:@"Bob"];
    //[[world_ makeCritterAtPos:(Position) {5, 5} ofSex:FEMALE] setName:@"Carol"];
    //[[world_ makeCritterAtPos:(Position) {5, 6} ofSex:FEMALE] setName:@"Dawn"];
    
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
