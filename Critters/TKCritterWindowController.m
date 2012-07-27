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
            [self logScreenMessage:[critter description]];
            [self logScreenMessage:@"\t"];
            [self logScreenMessage:[NSString stringWithFormat:@" Grid square count:%ld\n", [[square critters] count]]];
        }
    }
}

- (IBAction)evaluateClicked:(id)sender
{
    [[self document] evaluate];
}

#pragma mark Main stuff

#pragma mark Debug/dev stuff
- (void) logScreenMessage:(NSString *) msg
{
    NSTextStorage *textStorage = [debugTextView textStorage];
    [textStorage beginEditing];
    [textStorage replaceCharactersInRange:NSMakeRange([textStorage length], 0)
                                   withString:msg];
    [textStorage endEditing];
}

@end
