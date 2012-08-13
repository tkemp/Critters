//
//  TKCritterDetailView.h
//  Critters
//
//  Created by Tim Kemp on 12/08/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "TKCritter.h"

@class TKCritterWindowController;

@interface TKCritterDetailView : NSView

@property(assign) IBOutlet TKCritterWindowController * critterWC;
@property(assign) IBOutlet NSTextFieldCell * test;

- (void) setActiveCritter:(TKCritter *) critter;

@end
