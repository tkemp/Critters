//
//  TKResource.m
//  Critters
//
//  Created by Tim Kemp on 30/07/2012.
//
//

#import "TKResource.h"

@implementation TKResource
{
    CFUUIDRef uniqueID_;
}
@synthesize type;
@synthesize quantity;

- (id)init
{
    self = [super init];
    if (self) {
        uniqueID_ = CFUUIDCreate(kCFAllocatorDefault);
    }
    return self;
}

- (NSString *) uniqueID
{
    return CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uniqueID_));
}

@end
