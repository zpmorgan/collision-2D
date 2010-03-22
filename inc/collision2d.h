
typedef struct{
   Entity* ent1;
   Entity* ent2;
   float time;
   SV axis;
} Collision;


typedef struct{
   float x, y;
   float xv, yv;
   float relative_x, relative_y;
   float relative_xv, relative_yv;
} Entity;
