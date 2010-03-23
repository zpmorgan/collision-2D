#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "collision2d.h"

#ifndef aTHX_
#define aTHX_
#endif


MODULE = Collision::2D::Entity::Grid 	PACKAGE = Collision::2D::Entity::Grid    PREFIX = grid_

 # _new -- used internally
Grid *
grid__new (CLASS, x, y, xv, yv, relative_x, relative_y, relative_xv, relative_yv, w,h,cells_x,cells_y,cell_size)
	char* CLASS
	float  x
	float  y
	float  xv
	float  yv
	float  relative_x
	float  relative_y
	float  relative_xv
	float  relative_yv
   int w
   int h
   int cells_x
   int cells_y
   float  cell_size
	CODE:
		RETVAL = (Grid *) safemalloc (sizeof(Grid));
		RETVAL->x = x;
		RETVAL->y = y;
		RETVAL->xv = xv;
		RETVAL->yv = yv;
		RETVAL->relative_x = relative_x;
		RETVAL->relative_y = relative_y;
		RETVAL->relative_xv = relative_xv;
		RETVAL->relative_yv = relative_yv;
		RETVAL->w = w;
		RETVAL->h = h;
		RETVAL->cells_x = cells_x;
		RETVAL->cells_y = cells_y;
		RETVAL->cell_size = cell_size;
		AV* tablaeieu = newAV();
 		RETVAL->table = newRV_inc((SV*)tablaeieu);

	OUTPUT:
		RETVAL






void
grid_DESTROY(self)
	Grid *self
	CODE:
		SvREFCNT_dec ( (SV*) self->table );
		safefree( (char *)self );
