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

@interface TKTopDownWorldView : NSView

- (void) plotSquare:(TKGridSquare *) square;

@end
