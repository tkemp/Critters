//
//  constants.h
//  Critters
//
//  Created by Tim Kemp on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Critters_constants_h
#define Critters_constants_h

#define MALE YES
#define FEMALE NO
#define MAX_HEALTH 1.0
#define MAX_STRENGTH 1.0

typedef enum Action {
    Move,
    Eat,
    Fight,
    Mate,
    Nothing
} Action;

typedef enum Direction {
    North = 0,
    NorthEast = 1,
    East = 2,
    SouthEast = 3,
    South = 4,
    SouthWest = 5,
    West = 6,
    NorthWest = 7,
} Direction;

typedef struct Position {
    int col;
    int row;
} Position;

#endif
