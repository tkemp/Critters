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

@synthesize test;

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
    [test setTitle:@"Hello"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void) setActiveCritter:(TKCritter *)critter
{
    [test setTitle:critter.name];
}

@end
