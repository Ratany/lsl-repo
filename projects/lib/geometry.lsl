
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see
// <http://www.gnu.org/licenses/>.


#ifndef _GEOMETRY
#define _GEOMETRY

#ifndef fUNDETERMINED
#define fUNDETERMINED              -1.0
#endif  // fUNDETERMINED

#ifndef vUNDETERMINED
#define vUNDETERMINED              (<fUNDETERMINED, fUNDETERMINED, fUNDETERMINED>)
#endif  // vUNDETERMINED


#ifdef _GEOM_USE_segments

// segments around positions --- THESE ARE 3D
//
// The center is considered as 0/0.  All positions fed must be
// relative to the center.

#define center(_v)                                     ((_v.x == 0.0) && (_v.y == 0.0))

#define left(_v)                                       (_v.x < 0.0)
#define right(_v)                                      (_v.x > 0.0)
#define front(_v)                                      (_v.y > 0.0)
#define back(_v)                                       (_v.y < 0.0)

#define above(_v)                                      (_v.z > 0.0)
#define below(_v)                                      (_v.z < 0.0)


// flags
//
#define geom_segment_center                            1

#define geom_segment_left                              2
#define geom_segment_right                             4
#define geom_segment_front                             8
#define geom_segment_back                             16

#define geom_segment_above                            32
#define geom_segment_below                            64
//


// true when _p1 and _p2 share the given _segment
//
#define geom_cmpsegment(_segment, _p1, _p2)            (_segment(_p1)           && _segment(_p2))


// return an integer representing in which segment, using the segments
// defined above
//
// use like 'isincenter = geom_whichsegments(point) & geom_segment_center'
//
#define geom_whichsegments(_p)                        (center(_p) * geom_segment_center \
						       + left(_p) * geom_segment_left \
						       + right(_p) * geom_segment_right \
						       + front(_p) * geom_segment_front \
						       + back(_p) * geom_segment_back \
						       + above(_p) * geom_segment_above \
						       + below(_p) * geom_segment_below)

// number of segments shared by two points
//
#define geom_nofsharedsegments(_p1, _p2)	       (geom_cmpsegment(center, _p1, _p2) \
							+ geom_cmpsegment(left, _p1, _p2) \
							+ geom_cmpsegment(right, _p1, _p2) \
							+ geom_cmpsegment(front, _p1, _p2) \
							+ geom_cmpsegment(back, _p1, _p2) \
							+ geom_cmpsegment(above, _p1, _p2) \
							+ geom_cmpsegment(below, _p1, _p2)) \



// available as functions since it might save memory
//
#ifdef _GEOM_USE_geom_whichsegments3D

int geom_whichsegments3D(vector point)
{
	return geom_whichsegments(point);
}

#endif  // _GEOM_USE_whichsegments3D


#ifdef _GEOM_USE_geom_nofsharedsegments3D

int geom_nofsharedsegments3D(vector A, vector B)
{
	return geom_nofsharedsegments(A, B);
}

#endif  // _GEOM_USE_nofsharedsegments3D


#ifdef _GEOM_USE_geom_segments2list3D


#define geom_sCENTER                                   "center"
#define geom_sLEFT                                     "left"
#define geom_sRIGHT                                    "right"
#define geom_sFRONT                                    "front"
#define geom_sBACK                                     "back"
#define geom_sABOVE                                    "above"
#define geom_sBELOW                                    "below"



list geom_segments2list3D(vector p)
{
	int segments = geom_whichsegments(p);
	list ret = [];

	when(segments & geom_segment_center) ret += geom_sCENTER;
	when(segments & geom_segment_left) ret += geom_sLEFT;
	when(segments & geom_segment_right) ret += geom_sRIGHT;
	when(segments & geom_segment_front) ret += geom_sFRONT;
	when(segments & geom_segment_back) ret += geom_sBACK;
	when(segments & geom_segment_above) ret += geom_sABOVE;
	when(segments & geom_segment_below) ret += geom_sBELOW;

	return ret;
}


#undef geom_sCENTER
#undef geom_sLEFT
#undef geom_sRIGHT
#undef geom_sFRONT
#undef geom_sBACK
#undef geom_sABOVE
#undef geom_sBELOW


#endif  // _GEOM_USE_geom_segments2list3D


#undef center
#undef left
#undef right
#undef front
#undef back
#undef above
#undef below

#undef geom_cmpsegment
#undef geom_whichsegments
#undef geom_nofsharedsegments


#ifdef _GEOM_USE_segments_undef_flags

#undef geom_segment_center
#undef geom_segment_left
#undef geom_segment_right
#undef geom_segment_front
#undef geom_segment_back
#undef geom_segment_above
#undef geom_segment_below

#endif  // _GEOM_USE_segments_undef_flags




#endif  // _GEOM_USE_segments


//
// note: functions are 2D unless named 3D
//


#ifdef _GEOM_USE_geom_linecrosspoint

// compute the intersection point of two lines the start and end
// points of which are given in vectors A, B and C, D
//
// unless the lines cross, return vUNDETERMINED
//
// https://wiki.secondlife.com/wiki/Geometric#Line_and_Line.2C_intersection_point
//
vector geom_linecrosspoint(vector A, vector B, vector C, vector D)
{
	vector b = B - A;
	vector d = D - C;
	float dotperp = b.x * d.y - b.y * d.x;
	if (dotperp == 0.0) return vUNDETERMINED;

	vector c = C - A;
	float t = (c.x * d.y - c.y * d.x) / dotperp;
	return <A.x + t * b.x, A.y + t * b.y, 0>;
}

#endif  // _GEOM_USE_geom_linecrosspoint


#ifdef _GEOM_USE_geom_linescrossing

// as above, but return FALSE when the lines do not cross, otherwise
// return TRUE
//
bool geom_linescrossing(vector A, vector B, vector C, vector D)
{
	vector b = B - A;
	vector d = D - C;
	float dotperp = b.x * d.y - b.y * d.x;

	if (dotperp == 0.0) return FALSE;

	return TRUE;
}

#endif  // _GEOM_USE_geom_linescrossing


#ifdef _GEOM_USE_geom_linesegmentscross


// return TRUE if two line segments intersect, otherwise FALSE
//
// http://forum.unity3d.com/threads/17384-Line-Intersection
//
bool geom_linesegmentscross(vector p1, vector p2, vector p3, vector p4)
{
	vector a = p2 - p1;
	vector b = p3 - p4;
	vector c = p1 - p3;

	float alphaNumerator = b.y * c.x - b.x * c.y;
	float alphaDenominator = a.y * b.x - a.x * b.y;
	float betaNumerator  = a.x * c.y - a.y * c.x;
	float betaDenominator  = a.y * b.x - a.x * b.y;

	if((alphaDenominator == 0.0) || (betaDenominator == 0.0)) return FALSE;

	if(alphaDenominator > 0.0)
		{
			if((alphaNumerator < 0.0) || (alphaNumerator > alphaDenominator)) return FALSE;
		}
	else
		{
			if((alphaNumerator > 0.0) || (alphaNumerator < alphaDenominator)) return FALSE;
		}

	if(betaDenominator > 0.0)
		{
			if((betaNumerator < 0.0) || (betaNumerator > betaDenominator)) return FALSE;
		}
	else
		{
			if((betaNumerator > 0.0) || (betaNumerator < betaDenominator)) return FALSE;
		}

	return TRUE;
}


#if 0
// return TRUE if two line segments intersect, otherwise FALSE
//
// http://forum.unity3d.com/threads/17384-Line-Intersection
//
bool geom_linesegmentscross(vector p1, vector p2, vector p3, vector p4)
{
	vector a = p2 - p1;
	vector b = p3 - p4;
	vector c = p1 - p3;

	float alphaNumerator = b.y * c.x - b.x * c.y;
	float alphaDenominator = a.y * b.x - a.x * b.y;
	float betaNumerator  = a.x * c.y - a.y * c.x;
	float betaDenominator  = a.y * b.x - a.x * b.y;

	bool doIntersect = TRUE;

	if (alphaDenominator == 0.0 || betaDenominator == 0.0)
		{
			doIntersect = FALSE;
		}
	else
		{

			if (alphaDenominator > 0.0)
				{
					if (alphaNumerator < 0.0 || alphaNumerator > alphaDenominator)
						{
							doIntersect = FALSE;
						}
				}
			else
				{
					if (alphaNumerator > 0.0 || alphaNumerator < alphaDenominator)
						{
							doIntersect = FALSE;
						}
				}

			if (doIntersect && betaDenominator > 0.0)
				{
					if (betaNumerator < 0.0 || betaNumerator > betaDenominator)
						{
							doIntersect = FALSE;
						}
				}
			else
				{
					if (betaNumerator > 0.0 || betaNumerator < betaDenominator)
						{
							doIntersect = FALSE;
						}
				}
		}

	return doIntersect;
}
#endif  // 0

#endif  // _GEOM_USE_geom_linesegmentscross


#ifdef _GEOM_USE_geom_linesegmentintersection

// return the point at which two line segments intersect, otherwise
// return vUNDETERMINED
//
// http://forum.unity3d.com/threads/17384-Line-Intersection
//
vector geom_linesegmentintersection(vector p1, vector p2, vector p3, vector p4)
{
	float Ax;
	float Bx;
	float Cx;
	float Ay;
	float By;
	float Cy;
	float d;
	float e;
	float f;
	float num;

	float x1lo;
	float x1hi;
	float y1lo;
	float y1hi;

	Ax = p2.x - p1.x;
	Bx = p3.x - p4.x;

	// X bound box test/

	if(Ax < 0.0)
		{
			x1lo = p2.x;
			x1hi = p1.x;
		}
	else
		{
			x1hi = p2.x;
			x1lo = p1.x;
		}

	vector intersection = vUNDETERMINED;

	if(Bx > 0.0)
		{
			if(x1hi < p4.x || p3.x < x1lo) return intersection;
		}
	else
		{
			if(x1hi < p3.x || p4.x < x1lo) return intersection;
		}

	Ay = p2.y - p1.y;
	By = p3.y - p4.y;

	// Y bound box test//

	if(Ay < 0.0)
		{
			y1lo = p2.y;
			y1hi = p1.y;
		}
	else
		{
			y1hi = p2.y;
			y1lo = p1.y;
		}



	if(By > 0.0)
		{
			if(y1hi < p4.y || p3.y < y1lo) return intersection;
		}
	else
		{
			if(y1hi < p3.y || p4.y < y1lo) return intersection;
		}

	Cx = p1.x - p3.x;
	Cy = p1.y - p3.y;
	d = By * Cx - Bx * Cy; // alpha numerator//
	f = Ay * Bx - Ax * By; // both denominator//

	// alpha tests//

	if(f > 0.0)
		{
			if(d < 0.0 || d > f) return intersection;
		}
	else
		{
			if(d > 0.0 || d < f) return intersection;
		}

	e = Ax * Cy - Ay * Cx; // beta numerator//

	// beta tests //

	if(f > 0.0)
		{
			if(e < 0.0 || e > f) return intersection;
		}
	else
		{
			if(e > 0.0 || e < f) return intersection;
		}

	// check if they are parallel

	if(f == 0.0) return intersection;

	// compute intersection coordinates //

	num = d * Ax; // numerator //
	intersection.x = p1.x + num / f;

	num = d * Ay;
	intersection.y = p1.y + num / f;

	return intersection;
}

#endif  // _GEOM_USE_geom_linesegmentintersection


#undef fUNDETERMINED
#undef vUNDETERMINED

#endif  // _GEOMETRY
