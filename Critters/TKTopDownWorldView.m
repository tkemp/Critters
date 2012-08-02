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

@synthesize cols;
@synthesize rows;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _squaresToPlot = [[NSMutableSet alloc] initWithCapacity:self.cols * self.rows];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath * grid = [NSBezierPath bezierPath];
    
    float colWidth = dirtyRect.size.width / self.cols;
    float rowHeight = dirtyRect.size.height / self.rows;
    
    for (float i = 0; i <= dirtyRect.size.width; i += colWidth) {
        [grid moveToPoint:CGPointMake(i, 0)];
        [grid lineToPoint:CGPointMake(i, self.rows * rowHeight)];
    }
    for (float i = 0; i <= dirtyRect.size.height; i += rowHeight) {
        [grid moveToPoint:CGPointMake(0, i)];
        [grid lineToPoint:CGPointMake(self.cols * colWidth, i)];
    }
    
    for (TKGridSquare * square in _squaresToPlot) {
        long numCritters = [[square critters] count];
        float mkWidth = (colWidth / numCritters);
        float mkHeight = (rowHeight / numCritters);
        
        for (int i = 0; i < numCritters; i++) {
            TKCritter * critter = [[square.critters allObjects] objectAtIndex:i];
            NSColor * mkColor = [critter sex] == MALE ? [NSColor blueColor] : [NSColor redColor];
            CGPoint mkOrigin = CGPointMake(([square coordinates].col * colWidth) + (mkWidth * i), ([square coordinates].row * rowHeight) + (mkHeight * i));
            NSRect mkRect = NSMakeRect(mkOrigin.x, mkOrigin.y, mkWidth, mkHeight);
            NSBezierPath * marker = [NSBezierPath bezierPathWithRoundedRect:mkRect xRadius:1.0 yRadius:1.0];
            
            [[NSColor greenColor] setStroke];
            [mkColor setFill];
            [marker fill];
            [marker stroke];
        }
        
        for (int i = 0; i < square.resources.count; i++) {
            TKResource * resource = [[square.resources allObjects] objectAtIndex:i];
            if (Food == resource.type && resource.quantity > MIN_RESOURCE_QUANTITY) {
                NSColor * foodColor = [NSColor brownColor];
                CGPoint foodOrigin = CGPointMake(([square coordinates].col * colWidth) + (5 * i), ([square coordinates].row * rowHeight) + (5 * i));
                NSRect foodRect = NSMakeRect(foodOrigin.x, foodOrigin.y, 5, 5);
                NSBezierPath * foodMarker = [NSBezierPath bezierPathWithRoundedRect:foodRect xRadius:1.0 yRadius:3.0];
                
                [foodColor setFill];
                [foodMarker fill];
            }
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

#pragma mark Mouse handling
- (void) mouseUp:(NSEvent *)theEvent
{
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    float colWidth = self.bounds.size.width / self.cols;
    float rowHeight = self.bounds.size.height / self.rows;
    
    Position gridRef = (Position) { pt.x / colWidth, pt.y / rowHeight };
    
    NSLog(@"%d,%d", gridRef.col, gridRef.row);
}

- (void) mouseMoved:(NSEvent *)theEvent
{
    
}

@end
