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
#define OVERCROWDING_LIMIT 4

#pragma mark Typedefs

typedef BOOL Gender;

typedef enum Action {
    Move,
    Eat,
    Fight,
    Mate,
    Nothing
} Action;

typedef struct Position {
    int col;
    int row;
} Position;

typedef struct Direction {
    int dCol;
    int dRow;
} Direction;

typedef enum DirectionName {
    North = 0,
    NorthEast = 1,
    East = 2,
    SouthEast = 3,
    South = 4,
    SouthWest = 5,
    West = 6,
    NorthWest = 7,
    None = 8
} DirectionName;

typedef int foo;
typedef int bar;

static const struct Direction Directions[9] = {
    {0, 1}, // N
    {1, 1}, // NE
    {1, 0},  // E
    {1, -1},  // SE
    {0, -1},  // S
    {-1, -1}, // SW
    {-1, 0}, // W
    {-1, 1}, // NW
    {0, 0}   // None
};

static DirectionName randomDirection()
{
    return rand() % 9;
}

static BOOL matchPositions(Position a, Position b)
{
    return (a.col == b.col && a.row == b.row);
}

static BOOL matchDirections(Direction a, Direction b)
{
    return (a.dCol == b.dCol && a.dRow == b.dRow);
}

static DirectionName findDirection(Direction dv)
{
    for (int i = 0; i < 9; i++) {
        if (dv.dCol == Directions[i].dCol && dv.dRow == Directions[i].dRow)
            return i;
    }
    
    assert(false);
}

#endif
