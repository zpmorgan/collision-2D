
#DEFINE ENT_STUFF \
   float x, y; \
   float xv, yv;\
   float relative_x, relative_y;\
   float relative_xv, relative_yv;\
typedef struct Entity{
   ENT_STUFF
} Entity;

typedef struct Point{
   ENT_STUFF
} Point;

typedef struct Circle{
   ENT_STUFF
   float Radius;
} Point;

typedef struct Rect{
   ENT_STUFF
   float h,w;
} Point;
typedef struct Grid{
   ENT_STUFF
   AV* table;
   float h,w;
   int cells_x, cells_y;
   float cell_size;
} Point;

typedef struct Collision{
   Entity* ent1;
   Entity* ent2;
   float time;
   float axis_x;
   float axis_y;
} Collision;



