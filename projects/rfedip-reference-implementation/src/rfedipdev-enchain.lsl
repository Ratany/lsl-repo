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


// Ratany fine Engineering Interface Device Protocol device
//
// implementation of a device that queries another rfedip device for
// chaining points and then makes use of the points --- this device
// also makes its chain starting points available when the device
// itself is chained to something
//
// see https://wiki.secondlife.com/wiki/LSL_Protocol/rfedip
//
// Use this device to tie up your boats or airships or something :)


// rfedip documentation:
//
// This device can be queried for the UUIDs of prims to which chains
// can be attached.  The token to query the device is "tether".  The
// device replies with the token "tether point", followed by the UUID
// of a chaining point.  Each chaining point is reported in a seperate
// response message, one chaining point per message.  When all
// chaining points have been reported, this devices sends a
// RFEDIP_protEND control message.
//
// When this device is has not created chains itself, it does not
// report its chain target points but sends a RFEDIP_protEND control
// message instead.
//
// This device can send queries for the UUIDs of prims to which chains
// can be attached.  The token used for the query is "tether".  This
// device expects answers to this query to use the token "tether
// point", followed by the UUID of the point as parameter.  It expects
// devices that have received a query to indicate that all their
// UUUIDs have been reported by sending a a RFEDIP_protEND control
// message, regardless whether any points have been reported or not.
//


// You can select what to use as reference point for linking chains by
// segments: Depending on the particular object and on how the chain
// starting points are arranged, it can be better to use the geometric
// center of the object than it is to use the average positions of the
// chain starting points.  Alternatively, you can use the center of
// the bounding box of the object as reference.
//
// Code is provided for any of those, and which will be used depends
// on 'GeometricCenterIsReference' and 'BoundingBoxCenterIsReference'
// below.  The two are mutually exclusive.  It may also make sense to
// use a totally different point than any of those.
//
//
// Note: The algorithm does NOT consider in which segments relative to
// the object a chain starting point resides.  Instead, it figures out
// in which segments relative to the reference point a chain starting
// point resides.  Which segment that is changes with the rotation of
// the object.  The same is true for the segments of the chain target
// points.
//
// When an object is rotated in such a way that a chain starting point
// which was at the left back of the reference point is now at the
// front right of the reference point, its chain becomes likely to be
// linked to a target point which is also at the right front of the
// reference point.  Insofar the target points do not rotate with the
// object, the same chain would be linked to a different target point.
//
// When the object is rotated in between, it may look odd for human
// observers that a chain goes from what they perceive as the left
// back of the object to a target point which they perceive to be at
// the right back of the object.  This happens when the chain starting
// point, due to rotation, is actually at the left right of the
// reference point while the observers still see it as on the left
// back of the object and would put the chain to a target point which
// is also at the left back of the object.  The more the reference
// point is off of the middle point of the object, the stronger this
// effect may be, and the target point which is perceived as at the
// left back of the object may even be closer to the chaining point
// than the target point the algorithm links the chain to.
//
// Ideally, one would use the middle point of the object as reference
// point.  Unfortunately, what a human observer of the object would
// consider as middle point would be anything but easy to compute.
// Besides the points used here, for physical objects one could also
// experiment with llGetCenterOfMass().
//
// That the middle point of the object remains unknown and the
// uncomputable factor of human perception makes it impossible to get
// perfect results for all situations with a generic algorithm like
// this.  Good results for most situations will have to be sufficient
// here.
//
// Generally, the more evenly the chain starting points are
// distributed about the object --- for example, in an arrangement
// that resembles a circle along the circumference of the object ---
// the better it is to use the average position of the chain starting
// points as reference, especially when this average position diverges
// greatly from the geometric center of the object (or another
// reference point) in such a way that the geometric center (or the
// other reference point) is further off from what a human observer
// would percieve as middle point than the average position of the
// chain starting points is.
//
// You can adjust the reference point for a specific object you want
// to use this algorithm with by specifying it as an offset to the
// root prim.  You need to change the #defines of
// 'ObjectspecificIsReference' and 'vOBJECT_REFPOINT' for this.
//
// When you tie up a vehicle or other object which is moving while the
// algorithm is computing where to put which chain, you may get
// undesireable results because the movement of the object can
// invalidate the reference point.  If you cannot prevent the object
// from moving about while the computation is ongoing, you might get
// better results by using an external point as reference point, like
// the average positions of the chain target points.  Limiting which
// chain target points are considered, for example by distance and/or
// ownership, and even a suitable arrangement of the chain target
// points, may be required under such adverse conditions.
//
// To tie up an airship or boat that doesn´t stop moving, it may be
// advisable to use a sufficiently small (virtual) berth inside of
// which the entire airship needs to be before it can be tied down.
// Such a berth itself would use the rfedip protocol to interoperate
// with vehicles.  A particularly good reference point would be the
// middle point of the berth, which could be as simple to find out as
// the position of a box the vehicle tightly fits inside of is.
//
//
// When 'GeometricCenterIsReference' is defined as something that
// evaluates to TRUE, the geometric center of the object is used as
// reference.  When 'BoundingBoxCenterIsReference' is defined as
// something that evaluates to TRUE, the center of the objects´
// bounding box is used as reference.  When
// 'ObjectspecificIsReference' is defined as something that evaluates
// to TRUE, an offset to the root prim given in 'vOBJECT_REFPOINT' is
// used as reference.  When all these are defined as something that
// evaluates to TRUE, an error message will be printed.
//
// When all these are defined as something that evaluates to FALSE,
// the average position of the chain starting points is used as
// reference point.
//
// (Do not use TRUE or FALSE here unless you have defined them
// somewhere.  Use 1 and 0.)
//
#define GeometricCenterIsReference           0
#define BoundingBoxCenterIsReference         0
#define ObjectspecificIsReference            0
#if ObjectspecificIsReference
#define vOBJECT_REFPOINT                     (ZERO_VECTOR)
#endif
//


// This particular device can have multiple chains, created from the
// prims with names listed here.  Add as many chains as you like,
// until the script runs out of memory.
//
#define lCHAINTOS                  ["Chain-0", "Chain-1", "Chain-2", "Chain-3", "Chain-4", "Chain-5", "Chain-6", "Chain-7", "Chain-8", "Chain-9", "Chain-10", "Chain-11"]
//#define lCHAINTOS                  ["Chain-0", "Chain-1", "Chain-2", "Chain-3"]


// You can have tons of debugging output with these:
//
#define DEBUG0 0
#define DEBUG1 0
#define DEBUG2 0
#define fDEBUGSLEEP                10.0
//


//
// UNLESS YOU WANT TO CHANGE THE CHANGE THE SCRIPT, THERE ISN´T
// ANYTHING TO CHANGE BELOW THIS LINE
//


#define DEBUG DEBUG0 || DEBUG1 || DEBUG2


// some standard definitions
//
#include <lslstddef.h>
#include <colordef.h>

// use the getlinknumbersbylistnamedappend_attached() function from a
// library that provides functions to deal with names and descriptions
// of prims in order to figure out link numbers
//
#define _USE_getlinknumbersbylistnamedappend_attached_notnamed
#define _GETLINKNUMBERSBYLISTNAMEDAPPEND_ATTACHED_NOTNAMED_APPENDIX NULL_KEY
#include <getlinknumbers.lsl>

// use the geom_linecrosspoint() function from a library that provides
// functions that deal with geometry
//
#define _GEOM_USE_geom_linesegmentscross
#define _GEOM_USE_segments_undef_flags
#define _GEOM_USE_segments
#define _GEOM_USE_geom_nofsharedsegments3D

#if DEBUG2
#define _GEOM_USE_geom_segments2list3D
#endif

#include <geometry.lsl>
//
// this is defined to easily switch the very function used
//
#define boolChainsAreCrossing(_v1, _v2, _v3, _v4) geom_linesegmentscross(_v1, _v2, _v3, _v4)

// some standard definitions for rfedip:
//
#include <rfedip.h>

// some definitions from devices that communicate with this
// device
//
#include <rfedip-devices.h>


// The standard library (lslstddef.h) provides status handling, which
// requires an integer to store the status´ in:
//
int status;
#define stBUSY                     1
#define stRECEIVING                2
#define stHASCHAINS                4


key kThisDevice;                        // the UUID of this device

// Store the uniq identifier of this device in a string rather than
// calling llGetScriptName() many times --- the string will be
// initiated in the state_entry(), on_rez() and changed() events.  If
// your script is subject to frequent renaming, it may be advisable to
// use a local variable in the listen event instead.
//
string sThis_uniq;

// RFEDIP_sTHIS_UNIQ has been defined in rfedip.h, so redefine it.
// When rfedip.h is included after RFEDIP_sTHIS_UNIQ is defined, it
// doesn´t need to be undefined first.
//
#undef RFEDIP_sTHIS_UNIQ
#define RFEDIP_sTHIS_UNIQ          sThis_uniq

#define virtualIDinit					       \
	kThisDevice = llGetLinkKey(llGetLinkNumber());	       \
	sThis_uniq = llGetScriptName()


int iDevicesAround;                     // keep track of how many other devices have been found
#define iSTRIDE_lChains            2    // lChains is a strided list: [link number, uuid of target]
#define iINDEXOFFSET_lChains       1    // needed to deduct which chain is linked to a given target point
list lChains;                           // lChains is a strided list: [link number, uuid of target], see notes below
list lTargets;                          // a list of uuids of prims to leash to, as reported via rfedip

// a few macro definitions to deal with the chains
//
// Consider them as a demonstration of the incredible usefulness of a
// preprocessor.
//

#define boolChainLinked(_n)        (kChainKey(_n) != NULL_KEY)
#define iChainLinkNo(_n)           llList2Integer(lChains, (_n))
#define kChainKey(_n)              llList2Key(lChains, (_n) + 1)
#define sChainName(_n)             llList2String(GLPP(iChainLinkNo(_n), [PRIM_NAME]), 0)
#define vChainEndpos(_c)           RemotePos(kChainKey(_c))
#define vChainPos(_chain)          (llList2Vector(GLPP(iChainLinkNo(_chain), [PRIM_POSITION]), 0))
#define xChainHide(_n)             llLinkParticleSystem(iChainLinkNo(_n), [])
#define xChainShow(_n, _vcolour)   llLinkParticleSystem(iChainLinkNo(_n), CHAINS_lPARTICLE_CHAIN(_n, _vcolour))
#define yChainLink(_n, _k)         (lChains = llListReplaceList(lChains, (list)_k, (_n) + 1, (_n) + 1))
#define yChainUnlink(_n)           (lChains = llListReplaceList(lChains, (list)NULL_KEY, (_n) + 1, (_n) + 1))
#define yChainsInit                (lChains = getlinknumbersbylistnamedappend_attached_notnamed(lCHAINTOS))

#define LoopChains(_do)            int _n = Len(lChains); while(_n) { _n -= iSTRIDE_lChains; _do; }

#define kTargetKey(_target)        llList2Key(lTargets, _target)
#define sTargetName(_target)       RemoteName(kTargetKey(_target))
#define vTargetPos(_target)        RemotePos(kTargetKey(_target))

#define CHAINS_lPARTICLE_CHAIN(_n, _vc)  [					\
				      PSYS_PART_MAX_AGE, 3.0,		\
                                      PSYS_PART_FLAGS, PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_SRC_MASK | PSYS_PART_EMISSIVE_MASK, \
                                      PSYS_PART_START_COLOR, _vc, \
                                      PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>, \
                                      PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP, \
                                      PSYS_SRC_BURST_RATE, 0.04,	\
                                      PSYS_SRC_ACCEL, <0.0, 0.0, -1.2>,	\
                                      PSYS_SRC_BURST_PART_COUNT, 1,	\
                                      PSYS_SRC_BURST_SPEED_MIN, 3.0,	\
                                      PSYS_SRC_BURST_SPEED_MAX, 3.0,	\
                                      PSYS_SRC_TARGET_KEY, kChainKey(_n), \
                                      PSYS_SRC_MAX_AGE, 0.0,		\
                                      PSYS_SRC_TEXTURE, "4cde01ac-4279-2742-71e1-47ff81cc3529" \
				    ]

// unfortunately, this device needs a timer because messages can be
// lost, or no compliant devices might be around
//
#define fTIMER_UNWAIT              30.0

// sometimes stuff is undetermined
//
#define fUNDETERMINED              -1.0
#define iUNDETERMINED              -1
#define vUNDETERMINED              (<fUNDETERMINED, fUNDETERMINED, fUNDETERMINED>)
#define fIsUndetermined(_f)        (fUNDETERMINED == _f)
#define iIsUndetermined(_i)        (!~_i)
#define vIsUndetermined(_v)        (vUNDETERMINED == _v)



////////////////////////////////////////////////////////////////////////////////


// boolSegmentEndsAbove() is to handle a special case:  The function
// to determine whether two line segments cross or not considers two
// dimensions only (x and y coordinates).  This makes sense because it
// is somewhat unlikely for two chains to cross each other exactly
// when three dimensions (x, y and z coordinates) are considered.
//
// The special case is that the end points or starting points of two
// chains may have the same x and y coordinates while they have
// different z coordinates.  This happens when two target points or
// starting points are above each other.  The chains would be
// considered as crossing each other (at their end/start points),
// which is not desirable for this application.
//
// boolSegmentEndsAbove() is used to detect this special case,
// with some tolerance, and to make the chains considered as not
// crossing each other.  Doing this with some tolerance seems
// advisable not so much because of rounding errors but more so
// because prims may not be positioned too precisely.
//
bool boolSegmentEndsAbove(vector A, vector B, vector C, vector D)
{
	// let the preprocessor figure it out ...
	//
#define fTOLERANCEBY               100.0
#define tolerant(_f)               ((float)llRound(_f * fTOLERANCEBY) / fTOLERANCEBY)
#define cmpxy(_x, _y)              (tolerant(_x) == tolerant(_y))
#define cmpabz(_va, _vb)           (cmpxy(_va.x, _vb.x) && cmpxy(_va.y, _vb.y) && (_va.z != _vb.z))
#define cmp(_va, _vb, _vc, _vd)    (cmpabz(_va, _vb) || cmpabz(_vc, _vd))

	// ... and simply return the result of the comparison
	//
	return cmp(A, B, C, D);

#undef cmp
#undef cmpabz
#undef cmpxy
#undef tolerant
#undef fTOLERANCEBY

// This is only implemented as a function because it seems to eat less
// memory with this script that way.
//
}


// figure out which target shares the most segments with a chain and
// is closest to the chain starting point
//
int closest_shared(vector ref, int chain)
{
	vector chainpos = vChainPos(chain);
	vector chainrefpos = PosOffset(ref, chainpos);

	int shared = 0;
	int whicht = iUNDETERMINED;
	vector post;

	int t = Len(lTargets);
	while(t)
		{
			--t;

			vector thispos = vTargetPos(t);
			int segments = geom_nofsharedsegments3D(PosOffset(ref, thispos), chainrefpos);
			if(shared < segments)
				{
					shared = segments;
					whicht = t;
					post = thispos;
				}

		}

	when(iIsUndetermined(whicht)) return whicht;


	float maxdist = llVecDist(post, chainpos);

	int ret = iUNDETERMINED;

	t = Len(lTargets);
	while(t)
		{
			--t;

			vector thispos = vTargetPos(t);
			float thisdist = llVecDist(thispos, chainpos);
			when(thisdist < maxdist)
				{
					when(geom_nofsharedsegments3D(PosOffset(ref, thispos), chainrefpos) >= shared)
						{
							maxdist = thisdist;
							ret = t;
						}
				}
		}

	unless(iIsUndetermined(ret)) return ret;

	return whicht;
}


// figure out which chain target is closest to a given chain point
//
int closest_target(int chain)
{
	int ret = iUNDETERMINED;
	vector chainpos = vChainPos(chain);
	float closest = fUNDETERMINED;
	int n = Len(lTargets);
	while(n)
		{
			--n;

			float distance = llVecDist(vTargetPos(n), chainpos);
			if(fIsUndetermined(closest))
				{
					closest = distance;
					ret = n;
				}
			else
				{
					if(distance < closest)
						{
							closest = distance;
							ret = n;
						}
				}
		}

	DEBUGmsg0("closest target:", closest);
	return ret;
}


// swap the target points of two chains
//
void swap_chains(int ca, int cb)
{
	key tmp = kChainKey(ca);

	yChainLink(ca, kChainKey(cb));
	yChainLink(cb, tmp);
}


// figure out how many chains cross a given chain and pick one that
// crosses it
//
list find_chain_crossedby(int chain)
{
	vector start = vChainPos(chain);
	vector end = vChainEndpos(chain);

	int many = 0;
	int which = iUNDETERMINED;

	int c = Len(lChains);
	while(c)
		{
			c -= iSTRIDE_lChains;

			when((chain != c) && boolChainLinked(c))
				{
					vector cpos = vChainPos(c);
					vector cend = vChainEndpos(c);
					unless(boolSegmentEndsAbove(end, cend, start, cpos))
						{
							if(boolChainsAreCrossing(start, end, cpos, cend))
								{
									DEBUGmsg0(sChainName(c), "crosses", sChainName(chain));
									++many;
									which = c;
								}
						}
				}
		}

	return [which, many];
}


#if DEBUG
void show()
{
	DEBUGmsg("show intermediate results");
	LoopChains(when(boolChainLinked(_n)) { vector color = RandomColor; xChainShow(_n, color); SLPPF(iChainLinkNo(_n), [PRIM_TEXT, sChainName(_n), color, 1.0]); });
	llSleep(fDEBUGSLEEP);
}
#endif


void hide()
{
	aftell("removing chains");
	LoopChains(xChainHide(_n); yChainUnlink(_n));
	UnStatus(stHASCHAINS);
}


// tie up an object so that the result doesn´t look retarded
//
// caveats: It is undetermined whether a solution can be found in all
//          possible cases or not.
//
//          The algorithm scales horribly.
//
void mkchains()
{
	UnStatus(stRECEIVING);
	llSetTimerEvent(0.0);

	unless(Len(lChains) && Len(lTargets))
		{
			aftell("no chains or targets to work with");
			UnStatus(stBUSY);
			return;
		}

	aftell("computing ...");


	DEBUGmsg1("computing segment reference point");

#if BoundingBoxCenterIsReference && GeometricCenterIsReference && ObjectspecificIsReference
	ERRORmsg("'BoundingBoxCenterIsReference', 'GeometricCenterIsReference' and 'ObjectspecificIsReference' are mutually exclusive");
#else
#if ObjectspecificIsReference
	DEBUGmsg1("reference: object specific offset to root prim");
	vector refc = vOBJECT_REFPOINT * llGetRootRotation() + llGetRootPosition();
	int c;
#else
#if BoundingBoxCenterIsReference
	// use the center of the bbx of the object as reference
	//
	DEBUGmsg1("reference: bbx center");
	vector refc = BbxCenterPos(llGetKey());
	int c;
#else
#if GeometricCenterIsReference
	// use the geometric center of the object as reference point
	//
	DEBUGmsg1("reference: geometric center");

	vector refc = llGetGeometricCenter() * llGetRootRotation() + llGetRootPosition();
	int c;
#else
	// the average position of the chain points is the reference
	// point for the segments
	//
	DEBUGmsg1("reference: geometric center");

	vector refc = ZERO_VECTOR;
	int count = 0;
	int c = Len(lChains);
	while(c)
		{
			c -= iSTRIDE_lChains;
			refc += vChainPos(c);
			++count;
		}

	DEBUGmsg2(count, "chain points");
	refc /= (float)(count + !count);
#endif  // GeometricCenterIsReference
#endif  // BoundingBoxCenterIsReference
#endif  // ObjectspecificIsReference


	// link each chain to closest target that shares the most
	// segments with the chain point
	//
	DEBUGmsg1("linking by segments");

#if DEBUG
	DEBUGmsg("segment reference point:", refc);
	if(HasInventory("sph-stick"))
		{
			// to visualize the reference point, rezz a "stick" which deletes
			// itself after 120 seconds
			//
			llRezAtRoot("sph-stick", refc, ZERO_VECTOR, ZERO_ROTATION, 120);
		}
#endif

	c = Len(lChains);
	while(c)
		{
			c -= iSTRIDE_lChains;

			int t = closest_shared(refc, c);
			unless(iIsUndetermined(t))
				{
					DEBUGmsg2("chain", sChainName(c), "at", PosOffset(refc, vChainPos(c)), "is in segments", llList2CSV(geom_segments2list3D(PosOffset(refc, vChainPos(c)))));
					DEBUGmsg2("link", sChainName(c), "to", sTargetName(t), "(", t, ")", "at", PosOffset(refc, vTargetPos(t)), "which is in segments", llList2CSV(geom_segments2list3D(PosOffset(refc, vTargetPos(t)))));

					yChainLink(c, kTargetKey(t));
					lTargets = llDeleteSubList(lTargets, t, t);
				}
#if DEBUG2
			else
				{
					DEBUGmsg2("no target in segments of", sChainName(c));
				}
#endif
		}

#if DEBUG
	show();
#endif

	// restore targets
	//
	{ LoopChains(when(boolChainLinked(_n)) Enlist(lTargets, kChainKey(_n))); }

	// disentangle the chains
	//
	DEBUGmsg1("disentangling chains");

	int tries = Len(lChains);
	bool swapped;
	do
		{
			swapped = FALSE;

			c = Len(lChains);
			while(c)
				{
					c -= iSTRIDE_lChains;
					unless(boolChainLinked(c)) continue next_chain;

					// disentangle the chains: Swap this chain with another chain that
					// crosses this chain, unless swapping the chains entangles all of
					// them more.
					//

					// make the list returned by find_chain_crossedby() useable:
					//
#define xWhich(_l) llList2Integer(_l, 0)
#define xMany(_l)  llList2Integer(_l, 1)
					//

					list crosses = find_chain_crossedby(c);
					unless(iIsUndetermined(xWhich(crosses)))
						{
							DEBUGmsg0("swap:", sChainName(c), "and", sChainName(xWhich(crosses)), "/", xMany(crosses), "xings");

							swap_chains(c, xWhich(crosses));
							swapped = TRUE;

							list more = find_chain_crossedby(c);
							if(!iIsUndetermined(xWhich(more)) && (xMany(crosses) < xMany(more)))
								{
									DEBUGmsg0("unswap:", sChainName(c), "and", sChainName(xWhich(crosses)), "/", xMany(crosses), "xings vs.", xMany(more));

									swap_chains(c, xWhich(crosses));
									swapped = FALSE;
								}
#if DEBUG0
							else
								{
									DEBUGmsg0("no unswap:", xMany(more) - xMany(crosses), "xings");
								}
#endif
						}

#undef xMany
#undef xWhich

					// disentangle the chains even more: See if there is a target-point
					// closer to the chain-point of this chain which has an alternative
					// chain linked to it, and swap this chain and the alternative chain
					// when this chain and the alternative chain are crossing each other.
					//
					// (Swapping chains that do not cross each other can make them cross
					// each other, and they might be swapped back (by above), effectively
					// leading to swapping them back and forth indefinitely.)
					//
					// When there is a closer target with no chain linked to it, move this
					// chain over to the new target, unless the new target shares less
					// segments with the chain starting position than the current one.
					//
					int alternative_target = closest_target(c);
					unless(iIsUndetermined(alternative_target))
						{
							vector chainpos_c = vChainPos(c);
							vector endpos_c = vChainEndpos(c);
							vector endpos_alt = vTargetPos(alternative_target);

							if(llVecDist(chainpos_c, endpos_alt) < llVecDist(chainpos_c, endpos_c))
								{
									int alternative_chain = LstIdx(lChains, kTargetKey(alternative_target));
									unless(iIsUndetermined(alternative_chain))
										{
											alternative_chain -= iINDEXOFFSET_lChains;

											vector chainpos_alt = vChainPos(alternative_chain);

											unless(boolSegmentEndsAbove(endpos_c, endpos_alt, chainpos_c, chainpos_alt))
												{
													when(boolChainsAreCrossing(chainpos_c, endpos_c, chainpos_alt, endpos_alt))
														{
															DEBUGmsg0("swapping closer:", sChainName(c), "with", sChainName(alternative_chain));
															swap_chains(c, alternative_chain);
															swapped = TRUE;
														}
												}
										}
									else
										{
											DEBUGmsg0("no chain to swap with");

											vector rel_chainpos = PosOffset(refc, chainpos_c);
											when(geom_nofsharedsegments3D(rel_chainpos, PosOffset(refc, endpos_alt)) >= geom_nofsharedsegments3D(rel_chainpos, PosOffset(refc, endpos_c)))
												{
													DEBUGmsg0("moving", sChainName(c), "to", endpos_alt);
													yChainLink(c, kTargetKey(alternative_target));
													swapped = TRUE;
												}
#if DEBUG0
											else
												{
													DEBUGmsg0(sChainName(c), "--- new targets are not supposed to suddenly appear here");
												}
#endif
										}
								}
						}

					@next_chain;
				}
			--tries;
		}
	while(swapped && tries);

	// when the chains are linked and (hopefully) disentangled,
	// show the result:

	if(tries) aftell("solution found");

#if DEBUG
	show();
#else
	LoopChains(when(boolChainLinked(_n)) { vector color = RandomColor; xChainShow(_n, color); });
#endif

	SetStatus(stHASCHAINS);

#endif  // BoundingBoxCenterIsReference && GeometricCenterIsReference && ObjectspecificIsReference

	UnStatus(stBUSY);
	aftell("done");
}


// This is a version of the template modified for this particular
// device.
//
default
{
	event listen(int channel, string name, key other_device, string _MESSAGE)
	{
		// identify this device
		//
		when(ProtocolID(RFEDIP_protIDENTIFY_QUERY))
		{
			RFEDIP_RESPOND(other_device, RFEDIP_ToSENDER_UNIQ(ProtocolData(RFEDIP_sSEP)), kThisDevice, RFEDIP_CHANNEL, RFEDIP_protIDENTIFY);
			return;
		}

		// verify whether the received message looks like a
		// valid refdip-protocol message
		//
		list payload = ProtocolData(RFEDIP_sSEP);

		if(Len(payload) < RFEDIP_iMINMSGLEN)
			{
				return;
			}

		when((RFEDIP_ToSENDER(payload) != other_device) || (RFEDIP_ToRCPT(payload) != kThisDevice) || (RFEDIP_ToRCPT_UNIQ(payload) != RFEDIP_sTHIS_UNIQ) || !Instr(RFEDIP_ToPROTVERSION(payload), RFEDIP_sSUFFICIENT_VERSION))
			{
				return;
			}

		// extract the Uniq of the other device from the rfedip message
		//
		string uniq = RFEDIP_ToSENDER_UNIQ(payload);

		// extract the token from the rfedip message
		//
		string token = RFEDIP_ToFirstTOKEN(payload);

		//
		// ... to do some device specific stuff
		//
		// The order of the message handling has been arranged
		// for better performance.
		//

		when(protTETHER_RESPONSE == token)
			{
				// THIRD: Receive the responses to the query for points to attach chains to
				//        and remember those points.
				//
				Enlist(lTargets, RFEDIP_ToFirstPARAM(payload));
				return;
			}

		when(RFEDIP_protEND == token)
			{
				IfStatus(stRECEIVING)
				{
					// Receiving an end-message means that the device which sent it has finished
					// answering.
					//
					--iDevicesAround;
					iDevicesAround = Max(iDevicesAround, 0);  // ignore unexpected end-msgs

					// FOURTH: When all answers have been received, make the chains.
					//         In case an end-message gets lost, the timeout kicks in.
					//
					unless(iDevicesAround)
					{
						mkchains();
					}
				}

				return;
			}

		when(RFEDIP_protIDENTIFY == token)
			{
				// SECOND: Ask a device that identifies itself for points to attach chains to.
				//
				++iDevicesAround;
				RFEDIP_RESPOND(other_device, uniq, kThisDevice, RFEDIP_CHANNEL, protTETHER);
				return;
			}

		when(HasStatus(stHASCHAINS) && (RFEDIP_ToFirstTOKEN(payload) == protTETHER))
			{
				// allow others to chain up only when this device is tied

				LoopChains(RFEDIP_RESPOND(other_device, uniq, kThisDevice, RFEDIP_CHANNEL, protTETHER_RESPONSE, llGetLinkKey(iChainLinkNo(_n))));
				// RFEDIP_END(other_device, kThisDevice, RFEDIP_CHANNEL);
				// return;
			}

		unless(RFEDIP_protEND == token)
			{
				// when receiving messages not handled by this device,
				// indicate end of communication to potentially save
				// other devices unnecessary waiting times
				//
				// do not answer with com/end to com/end messages to avoid message loops!
				//
				RFEDIP_END(other_device, uniq, kThisDevice, RFEDIP_CHANNEL);
			}
	}

	event touch_start(int t)
	{
		unless(Len(lChains))
			{
				aftell("no chains to create");
				return;
			}

		IfStatus(stBUSY)
		{
			aftell("busy, please wait");
			return;
		}

		IfStatus(stHASCHAINS)
		{
			hide();
			return;
		}

		SetStatus(stBUSY);

		aftell("querying for devices");
		SoundPing;
		lTargets = [];

		// keep track of how many devices are detected to be
		// able to decide whether all answers from all devices
		// have been received or not
		//
		iDevicesAround = 0;

		// there isn´t a way around a timeout with this device :(
		//
		llSetTimerEvent(fTIMER_UNWAIT);

		// FIRST: query for rfedip-compliant devices
		//
		SetStatus(stRECEIVING);
		RFEDIP_IDQUERY;
	}

	event timer()
	{
		// A message indicating end of communication might not
		// have arrived.  Go ahead with whatever information
		// has been received so far.
		//
		apf("timeout,", iDevicesAround, "targets detected");
		mkchains();
	}

	event state_entry()
	{
		ClrStatus;
		yChainsInit;

#if DEBUG
		LoopChains(SLPPF(iChainLinkNo(_n), [PRIM_TEXT, sChainName(_n), GREEN, 1.0]));
#else
		LoopChains(SLPPF(iChainLinkNo(_n), [PRIM_TEXT, "", BLACK, 0.0]));
#endif

		virtualIDinit;
		llListen(RFEDIP_CHANNEL, "", NULL_KEY, "");
	}

	event changed(int w)
	{
		when(w & CHANGED_LINK)
			{
				// maybe do something else here if you need to sit on this device
				//
				hide();
				yChainsInit;
				virtualIDinit;
			}
	}

	event on_rez(int p)
	{
		virtualIDinit;
		hide();
	}
}
