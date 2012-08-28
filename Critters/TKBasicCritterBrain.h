//
//  TKBasicCritterBrain.h
//  Critters
//
//  Created by Tim Kemp on 20/08/2012.
//
//

#import <Foundation/Foundation.h>
#import "TKCritter.h"
#import "TKWorld.h"

@interface TKBasicCritterBrain : NSObject<TKCritterBrain>

+ (TKBasicCritterBrain *) sharedInstance;

@end
