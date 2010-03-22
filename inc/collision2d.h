
typedef struct Entity{
   float x, y;
   float xv, yv;
   float relative_x, relative_y;
   float relative_xv, relative_yv;
} Entity;

typedef struct Collision{
   Entity* ent1;
   Entity* ent2;
   float time;
   SV axis;
} Collision;



