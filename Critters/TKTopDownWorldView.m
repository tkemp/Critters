//
//  TKTopDownWorldView.m
//  Critters
//
//  Created by Tim Kemp on 26/07/2012.
//
//

#import "TKTopDownWorldView.h"

@implementation TKTopDownWorldView
{
    NSMutableSet * _squaresToPlot;
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _squaresToPlot = [[NSMutableSet alloc] initWithCapacity:8*8];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath * grid = [NSBezierPath bezierPath];
    
    float colWidth = dirtyRect.size.width / 8;
    float rowHeight = dirtyRect.size.height / 8;
    
    for (float i = 0; i <= dirtyRect.size.width; i += colWidth) {
        [grid moveToPoint:CGPointMake(i, 0)];
        [grid lineToPoint:CGPointMake(i, 8 * rowHeight)];
    }
    for (float i = 0; i <= dirtyRect.size.height; i += rowHeight) {
        [grid moveToPoint:CGPointMake(0, i)];
        [grid lineToPoint:CGPointMake(8 * colWidth, i)];
    }
    
    for (TKGridSquare * square in _squaresToPlot) {
        long numCritters = [[square critters] count];
        float mkWidth = (colWidth / numCritters);
        float mkHeight = (rowHeight / numCritters);
        
        for (int i = 0; i < numCritters; i++) {
            TKCritter * critter = [[[square critters] allObjects] objectAtIndex:i];
            NSColor * mkColor = [critter sex] == MALE ? [NSColor blueColor] : [NSColor redColor];
            CGPoint mkOrigin = CGPointMake(([square coordinates].col * colWidth) + (mkWidth * i), ([square coordinates].row * rowHeight) + (mkHeight * i));
            NSRect mkRect = NSMakeRect(mkOrigin.x, mkOrigin.y, mkWidth, mkHeight);
            NSBezierPath * marker = [NSBezierPath bezierPathWithRoundedRect:mkRect xRadius:1.0 yRadius:1.0];
            
            [[NSColor greenColor] setStroke];
            [mkColor setFill];
            [marker fill];
            [marker stroke];
        }
    }
    
    [[NSColor blackColor] setStroke];
    [grid stroke];
    [_squaresToPlot removeAllObjects];
}

- (void) plotSquare:(TKGridSquare *) square
{
    [_squaresToPlot addObject:square];
}

@end
