//
//  TKTopDownWorldView.h
//  Critters
//
//  Created by Tim Kemp on 26/07/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
#import "TKGridSquare.h"
#import "TKCritter.h"

@class TKCritterWindowController;

@interface TKTopDownWorldView : NSView

@property int cols;
@property int rows;
@property(assign) IBOutlet TKCritterWindowController * critterWC;

- (void) plotSquare:(TKGridSquare *) square;
- (void) removeCritterDisplay:(NSString *) critterID;
- (void) removeResourceDisplay:(NSString *) resourceID;

@end
