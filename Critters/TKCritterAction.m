//
//  TKCritterAction.m
//  Critters
//
//  Created by Tim Kemp on 27/07/2012.
//
//

#import "TKCritterAction.h"

@implementation TKCritterAction

@synthesize direction;
@synthesize action;

- (id) initWithDirection:(Direction)dir action:(Action)act
{
    self = [super init];
    if (self) {
        direction = dir;
        action = act;
    }
    
    return self;
}

@end
