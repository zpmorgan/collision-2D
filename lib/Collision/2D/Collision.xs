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
co__new (CLASS, ent1, ent2, time, axis)
	char* CLASS
	Entity * ent1
	Entity * ent2
	float  time
	SV * axis
	CODE:
		RETVAL = (Collision *) safemalloc (sizeof(Collision));
		RETVAL->ent1 = ent1;
		RETVAL->ent2 = ent2;
		RETVAL->time = time;
      if (!SvOK(axis)){  //axis is not defined
         RETVAL->axis_type = NO_AXIS;
      } else if (SvROK(axis)) { // axis is arrayref
         AV * axis_arr = (AV*)SvRV(axis);
         SV * axis_x = (*av_fetch (axis_arr, 0, 0));
         RETVAL->axis_x = SvNV(axis_x);
         SV * axis_y = (*av_fetch (axis_arr, 1, 0));
         RETVAL->axis_y = SvNV(axis_y);
         RETVAL->axis_type = VECTOR_AXIS;
      }
      else{
         char * axis_str = SvPV_nolen(axis);
         RETVAL->axis = axis_str[0]; //'x' or 'y'
         RETVAL->axis_type = XORY_AXIS;
      }

	OUTPUT:
		RETVAL


Entity *
co_ent1 ( self )
	Collision *self
	PREINIT:
		char* CLASS = "Collision::2D::Entity";
	CODE:
		RETVAL = self->ent1;
	OUTPUT:
		RETVAL

Entity *
co_ent2 ( self )
	Collision *self
	PREINIT:
		char* CLASS = "Collision::2D::Entity";
	CODE:
		RETVAL = self->ent2;
	OUTPUT:
		RETVAL

float
co_time ( co )
	Collision *co
	CODE:
		RETVAL = co->time;
	OUTPUT:
		RETVAL

SV *
co_axis ( self )
	Collision *self
	CODE:
      if (self->axis_type == NO_AXIS){
         RETVAL = newSVsv(&PL_sv_undef);
      }else if (self->axis_type == XORY_AXIS){
         RETVAL = newSVpvn (&self->axis, 1);
      }
      else{ //VECTOR_AXIS
         AV* axis_vec = newAV();
         av_push (axis_vec, sv_2mortal(newSVnv(self->axis_x)));
         av_push (axis_vec, sv_2mortal(newSVnv(self->axis_y)));
         RETVAL = newRV_inc((SV*) axis_vec);
      }
	OUTPUT:
		RETVAL


SV *
co_vaxis ( self )
   Collision *self
   ALIAS:
      maxis = 1
   CODE:
      if ( self->axis_type == NO_AXIS ){
         RETVAL = newSVsv(&PL_sv_undef);
      }
      else if (self->axis_type == VECTOR_AXIS) {
         AV* axis_vec = newAV();
         av_push (axis_vec, sv_2mortal(newSVnv(self->axis_x)));
         av_push (axis_vec, sv_2mortal(newSVnv(self->axis_y)));
         RETVAL = newRV_inc((SV*) axis_vec);
      } 
      else { //XORY_AXIS
         Entity *ent1 = self->ent1;
         if (self->axis == 'x'){
            AV* axis_vec = newAV();
            RETVAL = newRV_inc((SV*) axis_vec);
            if (ent1->relative_xv > 0){
               av_push (axis_vec, sv_2mortal(newSViv(1)));
            } else {
               av_push (axis_vec, sv_2mortal(newSViv(-1)));
            }
            av_push (axis_vec, sv_2mortal(newSViv(0)));
         } else { //'y'
            AV* axis_vec = newAV();
            RETVAL = newRV_inc((SV*) axis_vec);
            av_push (axis_vec, sv_2mortal(newSViv(0)));
            if (ent1->relative_yv > 0){
               av_push (axis_vec, sv_2mortal(newSViv(1)));
            } else {
               av_push (axis_vec, sv_2mortal(newSViv(-1)));
            }
         }
      }
   OUTPUT:
      RETVAL



void
co_DESTROY(self)
	Collision *self
	CODE:
		safefree( (char *)self );




