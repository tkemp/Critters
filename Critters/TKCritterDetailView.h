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

@property (weak) TKCritter * activeCritter;

@property(assign) IBOutlet TKCritterWindowController * critterWC;
@property(assign) IBOutlet NSTextFieldCell * txtCritterName;
@property(assign) IBOutlet NSTextFieldCell * txtCritterID;

@end
