//
//  TKResource.h
//  Critters
//
//  Created by Tim Kemp on 30/07/2012.
//
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface TKResource : NSObject

@property ResourceType type;
@property(readonly, strong) NSString * uniqueID;
@property float quantity;

@end
