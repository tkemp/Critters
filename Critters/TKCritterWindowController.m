//
//  TKCritterWindowController.m
//  Critters
//
//  Created by Tim Kemp on 26/07/2012.
//
//

#import "TKCritterWindowController.h"
#import "TKCritterDocument.h"

@implementation TKCritterWindowController

@synthesize worldView;
@synthesize debugTextView;
@synthesize document;

#pragma mark Startup & init code

- (id) init
{
    self = [super initWithWindowNibName:@"TKCritterDocumentWindow"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [worldView setCols:document.cols];
    [worldView setRows:document.rows];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logScreenMessage:) name:@"CritterConsoleLog" object:nil];
}

#pragma mark Action handlers
- (IBAction) makeCrittersClicked:(id) sender
{
    TKCritterDocument * doc = (TKCritterDocument *) [self document];
    [doc makeRandomPopulation];
}

- (IBAction) listCrittersClicked:(id) sender
{
    TKCritterDocument * doc = (TKCritterDocument *) [self document];
    for (int i = 0; i < [[doc world] cols] * [[doc world] rows]; i++) {
        TKGridSquare * square = [[doc world] gridSquareAtIndex:i];
        for (TKCritter * critter in [square critters]) {
            NSString * msg = [NSString stringWithFormat:@"%@ sharing: %ld\n", critter.description, square.critters.count];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CritterConsoleLog" object:msg];
        }
        [worldView plotSquare:square];
    }
    [worldView setNeedsDisplay:YES];
}

- (IBAction)evaluateClicked:(id)sender
{
    [[self document] evaluate];
    for (TKGridSquare * square in self.document.world.gridSquares) {
        [worldView plotSquare:square];
    }
    [worldView setNeedsDisplay:YES];
}

#pragma mark Main stuff


#pragma mark Debug/dev stuff
- (void) logScreenMessage:(NSNotification *) notification
{
    NSString * msg = [notification object];
    NSTextStorage *textStorage = [debugTextView textStorage];
    [textStorage beginEditing];
    [textStorage replaceCharactersInRange:NSMakeRange([textStorage length], 0)
                                   withString:msg];
    [textStorage endEditing];
}

@end
