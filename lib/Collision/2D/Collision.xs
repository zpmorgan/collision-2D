#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef aTHX_
#define aTHX_
#endif

typedef struct{
    Entity* ent1;
    Entity* ent2;
    float time;
    SV axis;
  } Collision;


MODULE = Collision::2D::Collision 	PACKAGE = Collision::2D::Collision    PREFIX = co_


Collision *
co__new (CLASS)
	char* CLASS
	CODE:
		RETVAL = (Collision *) safemalloc (sizeof(Collision));
		RETVAL->ent1 = SvIV(ST(1));
		RETVAL->ent2 = SvIV(ST(1));
		RETVAL->time = SvIV(ST(3));
		RETVAL->axis = SvIV(ST(4));

	OUTPUT:
		RETVAL


Entity *
co_ent1 ( co )
	Collision *co
   CODE:
		RETVAL = co->ent1;
	OUTPUT:
		RETVAL

Entity *
co_ent2 ( co )
	Collision *co
   CODE:
		RETVAL = co->ent2;
	OUTPUT:
		RETVAL

float
co_time ( co )
	Collision *co
   CODE:
		RETVAL = co->time;
	OUTPUT:
		RETVAL
float

SV *
co_axis ( co )
	Collision *co
   CODE:
		RETVAL = co->axis;
	OUTPUT:
		RETVAL

SV* //return an arrayref
co_maxis_foo ( co )
	Collision *co
   CODE:
      if (SvROK(co->axis)){  //is arrayref
         RETVAL = co->axis;
      }
      else{
         RETVAL = 42;
      }
	OUTPUT:
		RETVAL






