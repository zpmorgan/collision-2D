



typedef struct All_Entity_Stuff{
   float x, y; 
   float xv, yv;
   float relative_x, relative_y;
   float relative_xv, relative_yv;
   float radius; //circle
   float h,w; //rect, and also grid
   AV* table; //grid
   int cells_x, cells_y; //grid
   float cell_size;  //grid
} All_Entity_Stuff;


#define ENT_STUFF \
   float x, y; \
   float xv, yv;\
   float relative_x, relative_y;\
   float relative_xv, relative_yv;\
   float radius; \
   float h,w; \
   AV* table; \
   int cells_x, cells_y; \
   float cell_size; 

typedef struct Entity{
   ENT_STUFF
} Entity;

typedef struct Point{
   ENT_STUFF
} Point;

typedef struct Circle{
   ENT_STUFF
 //  float radius;
} Circle;

typedef struct Rect{
   ENT_STUFF
 //  float h,w;
} Rect;
typedef struct Grid{
   ENT_STUFF
 //  AV* table;
 //  float h,w;
 //  int cells_x, cells_y;
 //  float cell_size;
} Grid;



enum AXIS_TYPE {NO_AXIS, XORY_AXIS, VECTOR_AXIS};
//enum AXIS_XORY {X_AXIS, Y_AXIS};

typedef struct Collision{
   SV* ent1;
   SV* ent2;
   float time;
   int axis_type;
   char axis; // 'x' or 'y', if XORY_AXIS
   float axis_x; // if VECTOR_AXIS
   float axis_y; // if VECTOR_AXIS
} Collision;



