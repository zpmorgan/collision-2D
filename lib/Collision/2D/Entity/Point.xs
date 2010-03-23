#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "collision2d.h"

#ifndef aTHX_
#define aTHX_
#endif


MODULE = Collision::2D::Point 	PACKAGE = Collision::2D::Point    PREFIX = point_


Point *
point__new (CLASS, x, y, xv, yv, relative_x, relative_y, relative_xv, relative_yv)
	char* CLASS
	float  x
	float  y
	float  xv
	float  yv
	float  relative_x
	float  relative_y
	float  relative_xv
	float  relative_yv
	CODE:
		RETVAL = (Point *) safemalloc (sizeof(Point));
		RETVAL->x = x;
		RETVAL->y = y;
		RETVAL->xv = xv;
		RETVAL->yv = yv;
		RETVAL->relative_x = relative_x;
		RETVAL->relative_y = relative_y;
		RETVAL->relative_xv = relative_xv;
		RETVAL->relative_yv = relative_yv;

	OUTPUT:
		RETVAL




