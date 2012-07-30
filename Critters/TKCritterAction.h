//
//  TKCritterAction.h
//  Critters
//
//  Created by Tim Kemp on 27/07/2012.
//
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface TKCritterAction : NSObject

@property Direction direction;
@property Action action;

- (id) initWithDirection:(Direction) dir action:(Action) act;

@end
