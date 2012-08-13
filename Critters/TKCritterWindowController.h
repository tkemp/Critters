//
//  TKCritterWindowController.h
//  Critters
//
//  Created by Tim Kemp on 26/07/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "TKCritterDetailView.h"
#import "TKTopDownWorldView.h"

@class TKCritterDocument;

@interface TKCritterWindowController : NSWindowController
@property (weak) IBOutlet TKTopDownWorldView * worldView;
@property (weak) IBOutlet TKCritterDetailView * critterDetailView;
@property (unsafe_unretained) IBOutlet NSTextView *debugTextView;
@property (weak) TKCritterDocument * document;

- (IBAction)makeCrittersClicked:(id)sender;
- (IBAction)listCrittersClicked:(id)sender;
- (IBAction)evaluateClicked:(id)sender;

- (void) critterClickedWithID:(NSString *) critterID;

@end
