//
//  TKTopDownWorldView.m
//  Critters
//
//  Created by Tim Kemp on 26/07/2012.
//
//

#import "TKTopDownWorldView.h"
#import "TKCritterWindowController.h"

@implementation TKTopDownWorldView
{
    NSMutableSet * _squaresToPlot;
    CALayer * _baseLayer;
    NSMutableDictionary * _critterLayers;
    NSMutableDictionary * _resourceLayers;
}

@synthesize cols;
@synthesize rows;
@synthesize critterWC;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _critterLayers = [NSMutableDictionary dictionaryWithCapacity:self.rows * self.cols * 4];
        _resourceLayers = [NSMutableDictionary dictionaryWithCapacity:self.rows * self.cols * 4];
    }
    
    return self;
}

- (void) awakeFromNib
{
    _squaresToPlot = [[NSMutableSet alloc] initWithCapacity:self.cols * self.rows];
    _baseLayer = [CALayer layer];
    [self setLayer:_baseLayer];
    [self setWantsLayer:YES];
    [_baseLayer setFrame:self.frame];
    [_baseLayer setBounds:self.bounds];
    [_baseLayer setDelegate:self];
    [_baseLayer setNeedsDisplay];
}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (layer == _baseLayer) {
        [self drawGrid:layer inContext:ctx];
    }
    
    float colWidth = layer.frame.size.width / self.cols;
    float rowHeight = layer.frame.size.height / self.rows;
    
    for (TKGridSquare * square in _squaresToPlot) {
        long numCritters = [[square critters] count];
        float mkWidth = (colWidth / numCritters);
        float mkHeight = (rowHeight / numCritters);
        
        for (int i = 0; i < numCritters; i++) {
            TKCritter * critter = [[square.critters allObjects] objectAtIndex:i];
            CALayer * critLayer;
            // Create a new layer if needed
            if ((critLayer = [_critterLayers objectForKey:[critter uniqueID]]) == nil) {
                critLayer = [CALayer layer];
                [_critterLayers setObject:critLayer forKey:[critter uniqueID]];
                [_baseLayer addSublayer:critLayer];
            }
            
            NSColor * mkColor = [critter sex] == MALE ? [NSColor blueColor] : [NSColor redColor];
            CGPoint mkOrigin = CGPointMake(([square coordinates].col * colWidth) + (mkWidth * i), ([square coordinates].row * rowHeight) + (mkHeight * i));
            NSRect mkRect = NSMakeRect(mkOrigin.x, mkOrigin.y, mkWidth, mkHeight);
            
            [critLayer setFrame:mkRect];
            [critLayer setBackgroundColor:CGColorCreateGenericRGB(mkColor.redComponent, mkColor.greenComponent, mkColor.blueComponent, 1.0)];
            [critLayer setCornerRadius:6.0];
        }
        
        // Now process resources
        for (int i = 0; i < square.resources.count; i++) {
            TKResource * res = [[square.resources allObjects] objectAtIndex:i];
            if (Food == res.type && res.quantity > MIN_RESOURCE_QUANTITY) {
                CALayer * resLayer;
                if ((resLayer = [_resourceLayers objectForKey:[res uniqueID]]) == nil) {
                    resLayer = [CALayer layer];
                    [_resourceLayers setObject:resLayer forKey:[res uniqueID]];
                    [_baseLayer addSublayer:resLayer];
                }
                CGPoint foodOrigin = CGPointMake(([square coordinates].col * colWidth) + (5 * i), ([square coordinates].row * rowHeight) + (5 * i));
                NSRect foodRect = NSMakeRect(foodOrigin.x, foodOrigin.y, 5, 5);
                [resLayer setFrame:foodRect];
                [resLayer setBackgroundColor:CGColorCreateGenericRGB([[NSColor brownColor] redComponent], [[NSColor brownColor] greenComponent], [[NSColor brownColor] blueComponent], 1.0)];
                [resLayer display];
            }
        }
    }
    
    [_squaresToPlot removeAllObjects];
}

- (void) drawGrid:(CALayer *) layer inContext:(CGContextRef) ctx
{
    float colWidth = layer.frame.size.width / self.cols;
    float rowHeight = layer.frame.size.height / self.rows;
    
    // Draw the grid
    CGMutablePathRef grid = CGPathCreateMutable();
    CGContextBeginPath(ctx);
    
    for (float i = 0; i <= layer.frame.size.width; i += colWidth) {
        CGPathMoveToPoint(grid, NULL, i, 0);
        CGPathAddLineToPoint(grid, NULL, i, self.rows * rowHeight);
    }
    for (float i = 0; i <= layer.frame.size.height; i += rowHeight) {
        CGPathMoveToPoint(grid, NULL, 0, i);
        CGPathAddLineToPoint(grid, NULL, self.cols * colWidth, i);
    }
    
    [[NSColor blackColor] setStroke];
    
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, grid);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextStrokePath(ctx);
    CFRelease(grid);
}

- (void) plotSquare:(TKGridSquare *) square
{
    [_squaresToPlot addObject:square];
    [_baseLayer setNeedsDisplay];
}

- (void) removeCritterDisplay:(NSString *) critterID
{
    if ([_critterLayers objectForKey:critterID] != nil) {
        [[_critterLayers objectForKey:critterID] removeFromSuperlayer];
        [_critterLayers removeObjectForKey:critterID];
    }
}

- (void) removeResourceDisplay:(NSString *) resourceID
{
    if ([_resourceLayers objectForKey:resourceID] != nil) {
        [[_resourceLayers objectForKey:resourceID] removeFromSuperlayer];
        [_resourceLayers removeObjectForKey:resourceID];
    }
}

#pragma mark Mouse handling
- (void) mouseUp:(NSEvent *)theEvent
{
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    float colWidth = self.bounds.size.width / self.cols;
    float rowHeight = self.bounds.size.height / self.rows;
    
    Position gridRef = (Position) { pt.x / colWidth, pt.y / rowHeight };
    
    NSLog(@"%d,%d", gridRef.col, gridRef.row);
    
    CALayer * clickedOn = [_baseLayer hitTest:pt];
    if (clickedOn != _baseLayer) {
        for (NSString * critID in [_critterLayers allKeys]) {
            if ([_critterLayers objectForKey:critID] == clickedOn) {
                [critterWC critterClickedWithID:critID];
            }
        }
    }
}

- (void) mouseMoved:(NSEvent *)theEvent
{
    
}

@end
