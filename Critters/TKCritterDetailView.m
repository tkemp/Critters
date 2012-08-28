//
//  TKCritterDetailView.m
//  Critters
//
//  Created by Tim Kemp on 12/08/2012.
//
//

#import "TKCritterDetailView.h"
#import "TKCritterWindowController.h"

@implementation TKCritterDetailView
{
    TKCritter * activeCritter_;
}

@synthesize txtCritterName;
@synthesize txtCritterID;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) awakeFromNib
{
    [txtCritterName setTitle:@"Hello"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (TKCritter *) activeCritter
{
    return activeCritter_;
}

- (void) setActiveCritter:(TKCritter *) critter
{
    activeCritter_ = critter;
}

@end
