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
#define MIN_HEALTH_INCREMENT 0.05
#define MIN_STRENGTH_INCREMENT 0.05
#define OVERCROWDING_LIMIT 4
#define MIN_RESOURCE_QUANTITY 0.0
#define MAX_RESOURCE_QUANTITY 1.0

#pragma mark Notifications
#define NTFY_CONSOLE_LOG @"NotificationCritterConsoleLog"
#define NTFY_CRITTER_DIED @"NotificationCritterDied"
#define NTFY_RESOURCE_DEPLETED @"NotificationResourceDepleted"

#pragma mark Critter & world information

typedef enum WorldEvent {
    CritterDied,
    ResourceDepleted
} WorldEvent;

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
    DirNorth = 0,
    DirNorthEast = 1,
    DirEast = 2,
    DirSouthEast = 3,
    DirSouth = 4,
    DirSouthWest = 5,
    DirWest = 6,
    DirNorthWest = 7,
    DirNone = 8
} DirectionName;

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

typedef enum ResourceType {
    Food = 0,
    Danger = 1
} ResourceType;

#pragma mark Utility functions

static DirectionName randomDirection()
{
    return rand() % 9;
}

static Position randomPosition(int cols, int rows)
{
    return (Position) { rand() % cols, rand() % rows };
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
