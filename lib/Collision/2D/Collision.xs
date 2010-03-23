#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "collision2d.h"

#ifndef aTHX_
#define aTHX_
#endif


MODULE = Collision::2D::Collision 	PACKAGE = Collision::2D::Collision    PREFIX = co_


 # _new -- used internally
Collision *
co__new (CLASS, ent1, ent2, time, axis_x, axis_y)
	char* CLASS
	Entity * ent1
	Entity * ent2
	float  time
	float  axis_x
	float  axis_y
	CODE:
		RETVAL = (Collision *) safemalloc (sizeof(Collision));
		RETVAL->ent1 = ent1;
		RETVAL->ent2 = ent2;
		RETVAL->time = time;
		RETVAL->axis_x = axis_x;
		RETVAL->axis_y = axis_y;

	OUTPUT:
		RETVAL


Entity *
co_ent1 ( co )
	Collision *co
	PREINIT:
		char* CLASS = "Collision::2D::Entity";
	CODE:
		RETVAL = co->ent1;
	OUTPUT:
		RETVAL

Entity *
co_ent2 ( co )
	Collision *co
	PREINIT:
		char* CLASS = "Collision::2D::Entity";
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

AV *
co_axis ( co )
	Collision *co
	CODE:
		RETVAL = (AV*)sv_2mortal((SV*)newAV());
		av_push(RETVAL, newSVnv(co->axis_x) );
		av_push(RETVAL, newSVnv(co->axis_y) );
	OUTPUT:
		RETVAL


AV *
co_maxis_foo ( co )
	Collision *co
	CODE:
	      //if ( co->axis_y ){  //is arrayref
			RETVAL = (AV*)sv_2mortal((SV*)newAV());
			av_push(RETVAL, newSVnv(co->axis_x) );
			av_push(RETVAL, newSVnv(co->axis_y) );
	      //}
	     // else{
		// RETVAL = (AV*)sv_2mortal((SV*)newAV());
	     // }
	OUTPUT:
		RETVAL



void
co_DESTROY(self)
	Collision *self
	CODE:
		safefree( (char *)self );




