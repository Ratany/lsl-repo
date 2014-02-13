
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


// standard defines for scripts

#ifndef _LSLSTDDEF
#define _LSLSTDDEF


#define int                             integer
#define bool                            integer
#define NotOnlst(_list, ...)            (!~llListFindList(_list, [__VA_ARGS__]))
#define Onlst(_list, ...)               (~llListFindList(_list, [__VA_ARGS__]))
#define LstIdx(_list, ...)              llListFindList(_list, [__VA_ARGS__])
#define Enlist(_list, ...)              if(MFree && !~llListFindList(_list, [__VA_ARGS__])) { _list += [__VA_ARGS__]; }
#define IfEnlist(_list, _do, ...)       if(MFree && !~llListFindList(_list, [__VA_ARGS__])) { _list += [__VA_ARGS__]; _do; }
//#define IfNotEnlist(_list, _do, ...)  if(MFree && !~llListFindList(_list, [__VA_ARGS__])) { _list += [__VA_ARGS__]; } else { _do; }
//#define IfElseEnlist(_list, _doif, _doelse, ...) if(MFree && !~llListFindList(_list, [__VA_ARGS__])) { _list += [__VA_ARGS__]; _doif; } else { _doelse; }
#define Len(_list)                      llGetListLength(_list)
#define FMin(x, y)                      ( (  (llFabs( (x) >= (y) )  ) * (y) ) + ( (llFabs( (x) < (y) )  ) * (x) )  )
#define Min(x, y)                       ( (  (llAbs( (x) >= (y) )  ) * (y) ) + ( (llAbs( (x) < (y) )  ) * (x) )  )
#define FMax(x, y)                      ( (  (llFabs( (x) >= (y) )  ) * (x) ) + ( (llFabs( (x) < (y) ) ) * (y) ) )
#define Max(x, y)                       ( (  (llAbs( (x) >= (y) )  ) * (x) ) + ( (llAbs( (x) < (y) ) ) * (y) ) )
#define FVecMax(_v)                     (FMax(_v.x, FMax(_v.y, _v.z) ) )
#define FVecMin(_v)                     (FMin(_v.x, FMin(_v.y, _v.z) ) )
//#define VecMult(_d, _v, _x, _y, _z)     _d.x = _v.x * (_x); _d.y = _v.y * (_y); _d.z = _v.z * (_z)
#define VecTimesVec(_va, _vb)           _va.x *= _vb.x; _va.y *= _vb.y; _va.z *= _vb.z
#define PosOffset(_vhere, _vthere)      ( (_vthere) - (_vhere) )
#define VecSum(_v)                      (_v.x + _v.y + _v.z)
#define VecSubFAbs(_v1, _v2)            <llFabs(_v1.x - _v2.x), llFabs(_v1.y - _v2.y), llFabs(_v1.z - _v2.z) >
#define VecRound(_v, _fac)              _v = < (float)llRound(_v.x * (_fac) ) / (_fac), \
                                               (float)llRound(_v.y * (_fac) ) / (_fac), \
                                               (float)llRound(_v.z * (_fac) ) / (_fac) >

#define VecRound2Int(_v)                _v = < (float)llRound(_v.x),	\
		                               (float)llRound(_v.y),	\
		                               (float)llRound(_v.z) >

// to compare a set of positions to find mincorner and maxcorner for a bbx out of the positions
#define VFakeMin(_v1, _v2)              <FMin(_v1.x, _v2.x), FMin(_v1.y, _v2.y), FMin(_v1.z, _v2.z) >
#define VFakeMax(_v1, _v2)              <FMax(_v1.x, _v2.x), FMax(_v1.y, _v2.y), FMax(_v1.z, _v2.z) >

#define Signof(_f)                      ( (_f > 0.0) - (_f < 0.0) )

#ifdef _NO_INLINE_Dist2Line
float Dist2Line(vector _linestart, vector _lineend, vector _pos) {
  float a = llVecDist(_lineend, _pos);
  float b = llVecDist(_linestart, _pos);
  float c = llVecDist(_linestart, _lineend);
  float s = (0.5 * (a + b + c) );
  return (2.0 / c) * llSqrt(s * (s - a) * (s - b) * (s - c) );
}


/* float blup(vector _linestart, vector _lineend, vector _pos) { */
/* #define a  llVecDist( (_lineend), (_pos) ) */
/* #define b  llVecDist((_linestart), (_pos) ) */
/* #define c  llVecDist((_linestart), (_lineend) ) */
/* #define s  (0.5 * (a + b + c) ) */
/* #define hc (2.0 / c) * llSqrt(s * (s - a) * (s - b) * (s - c) ) */
/*   return hc */
/* } */


#else
#define Dist2Line(_linestart, _lineend, _pos)  (2.0 / llVecDist((_linestart), (_lineend) )) * llSqrt((0.5 * (llVecDist( (_lineend), (_pos) ) + llVecDist((_linestart), (_pos) ) + llVecDist((_linestart), (_lineend) )) ) * ((0.5 * (llVecDist( (_lineend), (_pos) ) + llVecDist((_linestart), (_pos) ) + llVecDist((_linestart), (_lineend) )) ) - llVecDist( (_lineend), (_pos) )) * ((0.5 * (llVecDist( (_lineend), (_pos) ) + llVecDist((_linestart), (_pos) ) + llVecDist((_linestart), (_lineend) )) ) - llVecDist((_linestart), (_pos) )) * ((0.5 * (llVecDist( (_lineend), (_pos) ) + llVecDist((_linestart), (_pos) ) + llVecDist((_linestart), (_lineend) )) ) - llVecDist((_linestart), (_lineend) )) )
#endif

// _v /= 2.0;
//#define VecHalf(_v)                     _v.x /= 2.0; _v.y /= 2.0; _v.z /= 2.0
#define VecFAbsSum(_ret, _v)            _ret = llFabs(_v.x) + llFabs(_v.y) + llFabs(_v.z)
#define VecBetween(_p0, _p1, _w)        (_p0 + (_p1 - _p0) * (_w) )

#define VecWithin(v, edge_min, edge_max) ( (  (v.x <= edge_max.x) + (v.x >= edge_min.x) \
                                           + (v.y <= edge_max.y) + (v.y >= edge_min.y) \
                                           + (v.z <= edge_max.z) + (v.z >= edge_min.z) ) == 6)

// to compare the size of a prim with the size of another to find out wich
// prim has the longest side (for growing trees ...)
#define SizecmpPrim(_va, _vb)           ( (FMax(FMax(_va.x, _va.y), _va.z) > FMax(FMax(_vb.x, _vb.y), _vb.z) )  )

// macros for status processing:
#define ClrStatus                       status = 0

// HasStatus() returns 1 when the status is set
#define HasStatus(_which)               ( !!(status & _which) )
#define NotStatus(_which)               ( !(status & _which) )
#define SetStatus(_which)               (status += _which * !(status & _which) )
#define UnStatus(_which)                (status -= _which * HasStatus(_which) )
#define CompStatus(_which, _yes)        (status += _which * NotStatus(_which) * !!(_yes) - _which * HasStatus(_which) * !(_yes) )
#define IfStatus(_which)                if(HasStatus(_which) )
#define IfNStatus(_which)               if(NotStatus(_which) )
#define IfNStatusDo(_which, _do)        if(NotStatus(_which)) { do; }
#define IfStatusDo(_which, _do)         if(HasStatus(_which)) { do; }


#define RemoteOwner(_key)                    llList2Key(llGetObjectDetails(_key, [OBJECT_OWNER] ), 0)
#define RemoteOwnerName(_key)                llKey2Name(RemoteOwner(_key) )
#define RemoteGroup(_key)                    llList2Key(llGetObjectDetails(_key, [OBJECT_GROUP] ), 0)

#define Ownerchk(_key)                       ( (RemoteOwner(_key) == llGetOwner() ) \
                                               || ( (RemoteOwner(_key) == NULL_KEY) \
                                               && (RemoteGroup(_key) == llGetOwner() )  )   )
// Ownerchk() is deprecated, use SameOwner()
#define SameOwner(_key)                      Ownerchk(_key)

#define AgentIsHere(_k)                      (llGetAgentSize(_k) != ZERO_VECTOR)
#define ObjectMaybeNotAround(_k)             (llKey2Name(_k) == "")

#define RemoteDesc(_key)                     llList2String(llGetObjectDetails(_key, [OBJECT_DESC] ), 0)
#define RemoteIsAttached(_key)               llList2Integer(llGetObjectDetails(_key, [OBJECT_ATTACHED_POINT]))

// There is a difference between llKey2Name() and llGetObjectDetails().
//
#define RemoteName(_key)                     llKey2Name(_key)
#define RemoteNameOD(_key)                   llList2String(llGetObjectDetails(_key, [OBJECT_NAME] ), 0)
#define RemotePhantom(_key)                  (llList2Integer(llGetObjectDetails(_key, [OBJECT_PHANTOM] ), 0) == TRUE)
#define RemotePhysCost(_key)                 llList2Float(llGetObjectDetails(_key, [OBJECT_PHYSICS_COST]), 0)
#define RemotePos(_key)                      llList2Vector(llGetObjectDetails(_key, [OBJECT_POS] ), 0)
#define RemotePrimEqv(_key)                  llList2Integer(llGetObjectDetails(_key, [OBJECT_PRIM_EQUIVALENCE] ), 0)
#define RemoteRScriptCount(_key)             llList2Integer(llGetObjectDetails(_key, [OBJECT_RUNNING_SCRIPT_COUNT] ), 0)
#define RemoteRoot(_key)                     llList2Key(llGetObjectDetails(_key, [OBJECT_ROOT] ), 0)
#define RemoteRootPos(_key)                  llList2Vector(llGetObjectDetails(RemoteRoot(_key), [OBJECT_POS] ), 0)
#define RemoteRootRot(_key)                  llList2Rot(llGetObjectDetails(RemoteRoot(_key), [OBJECT_ROT] ), 0)
#define RemoteRot(_key)                      llList2Rot(llGetObjectDetails(_key, [OBJECT_ROT] ), 0)
#define RemoteScriptTime(_key)               ( (float)llRound(llList2Float(llGetObjectDetails(_key, [OBJECT_SCRIPT_TIME] ), 0) * 1000000.0) / 100.0)
#define RemoteServerCost(_key)               llList2Float(llGetObjectDetails(_key, [OBJECT_SERVER_COST]), 0)
#define RemoteStreamCost(_key)               llList2Float(llGetObjectDetails(_key, [OBJECT_STREAMING_COST]), 0)
#define RemoteTScriptCount(_key)             llList2Integer(llGetObjectDetails(_key, [OBJECT_TOTAL_SCRIPT_COUNT] ), 0)
#define RemoteVelocity(_key)                 llVecMag(llList2Vector(llGetObjectDetails(_key, [OBJECT_VELOCITY] ), 0) )

#define RemoteIsHere(_key)                   (!!Len(llGetObjectDetails(_key, [OBJECT_POS])))

#define SameParcel(_k1, _k2)                 (llList2Key(llGetParcelDetails(RemotePos(_k1), [PARCEL_DETAILS_ID] ), 0) == llList2Key(llGetParcelDetails(RemotePos(_k2), [PARCEL_DETAILS_ID] ), 0) )
#define VSameParcel(_v, _k2)                 (llList2Key(llGetParcelDetails(_v, [PARCEL_DETAILS_ID] ), 0) == llList2Key(llGetParcelDetails(RemotePos(_k2), [PARCEL_DETAILS_ID] ), 0) )
#define VVSameParcel(_v, _v2)                (llList2Key(llGetParcelDetails(_v, [PARCEL_DETAILS_ID] ), 0) == llList2Key(llGetParcelDetails(_v2, [PARCEL_DETAILS_ID] ), 0) )

#define GetMenuChannel                       (-llGetUnixTime() - (int)llFrand((float)llGetUnixTime()) - 100)

// used with growing
// just the corners without rotation
#define BbxCorners(_k, _v1, _v2)        _v1 = llList2Vector(llGetBoundingBox(_k), 0); \
                                        _v2 = llList2Vector(llGetBoundingBox(_k), 1)

// position of the corners considering rotation
#define BbxCornerPos(_k, _v1, _v2)      _v1 = llList2Vector(llGetBoundingBox(_k), 0) * RemoteRot(_k) \
                                              + RemotePos(_k); \
                                        _v2 = llList2Vector(llGetBoundingBox(_k), 1) * RemoteRot(_k) \
                                              + RemotePos(_k)
// hmm
#define BbxScale(_k)                    ( (llList2Vector(llGetBoundingBox(_k), 1) \
                                           - llList2Vector(llGetBoundingBox(_k), 0) ) * 0.5)

#define BbxCenterPos(_k)                 (llGetRootPosition() + (llList2Vector(llGetBoundingBox(_k), 0) + llList2Vector(llGetBoundingBox(_k), 1)) * 0.5)

//#define GetRootRot                      llList2Rot(llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_ROTATION] ), 0)
#define GetRootRot                      llGetRootRotation()
#define GetPrimText(_which)             llList2String(llGetLinkPrimitiveParams(_which, [PRIM_TEXT] ), 0)


// orientation refers to an unrotated box
#define BbxFrontTopLeftCorner(_k, _v)   _v = BbxCenterPos(_k) + BbxScale(_k) * GetRootRot
#define BbxFrontTopRightCorner(_k, _v)  _v = BbxScale(_k); _v = BbxCenterPos(_k) + <_v.x, -_v.y, _v.z> * GetRootRot
#define BbxFrontBotLeftCorner(_k, _v)   _v = BbxScale(_k); _v = BbxCenterPos(_k) + <_v.x, _v.y, -_v.z> * GetRootRot
#define BbxFrontBotRightCorner(_k, _v)  _v = BbxScale(_k); _v = BbxCenterPos(_k) + <_v.x, -_v.y, -_v.z> * GetRootRot

#define BbxRearBotRightCorner(_k, _v)   _v = BbxCenterPos(_k) - BbxScale(_k) * GetRootRot
#define BbxRearTopRightCorner(_k, _v)   _v = BbxScale(_k); _v = BbxCenterPos(_k) + < -_v.x, -_v.y, _v.z> * GetRootRot
#define BbxRearBotLeftCorner(_k, _v)    _v = BbxScale(_k); _v = BbxCenterPos(_k) + < -_v.x, _v.y, -_v.z> * GetRootRot
#define BbxRearTopLeftCorner(_k, _v)    _v = BbxScale(_k); _v = BbxCenterPos(_k) + < -_v.x, _v.y, _v.z> * GetRootRot


// DO NOT USE for INVENTORY_ALL
// http://wiki.secondlife.com/wiki/LlGetInventoryType
//
// integer InventoryExists(string name, integer type) {
//   return (llGetInventoryType(name) == type) ^ (!~type);
// } // Since INVENTORY_ALL == INVENTORY_NONE
#define HasInventory(_name)                  (llGetInventoryType(_name) != INVENTORY_NONE)
#define NotInventory(_name)                  (llGetInventoryType(_name) == INVENTORY_NONE)

#define Velocity                             llVecMag(llGetVel() )

#define tif(_now, _then, _duration)          if(_now > _then + _duration)


// string macros
//
#define Strlen(_string)                      llStringLength(_string)
#define Substr(_string, _start, _end)        llGetSubString(_string, _start, _end)
#define Begstr(_string, _end)                llGetSubString(_string, 0, _end)
#define Endstr(_string, _start)              llGetSubString(_string, _start, -1)
#define Strtrunc(_str, _n)                   if(Strlen((_str)) > (_n)) _str = Begstr((_str), (_n) - 1)
#define Instr(_src, _tst)                    (~llSubStringIndex(_src, _tst) )
#define Stridx(_src, _tst)                   llSubStringIndex(_src, _tst)
//
// replace char in string
#define StrX(_str, _what, _with)             llDumpList2String(llParseStringKeepNulls(_str, [_what], []), _with)
//
// replace some chars in a string to savely convert it to CSV
#define CSVStrX(_s)                          StrX(StrX(StrX(_s, ",", "."), "<", "{"), ">", "}")
//

// concatenate strings
#define concat(_s1, _s2)                     ((_s1) + (_s2))
#define concats(_s1, _s2)                    ((_s1) + "|" + (_s2))


// region, position --> slurl
#define RPos2Slurl(_r, _v)                   llEscapeURL("http://slurl.com/secondlife/" + _r + "/" + _v.x + "/" + _v.y + "/" + _v.z + "/")

#define AbsVecOffset(_ret, _vec1, _vec2)     _ret.x = llFabs(_vec1.x - _vec2.x); \
                                             _ret.y = llFabs(_vec1.y - _vec2.y); \
					     _ret.z = llFabs(_vec1.z - _vec2.z)

#define MultVec(_ret, _vec)                  _ret.x *= _vec.x; \
                                             _ret.y *= _vec.y; \
                                             _ret.z *= _vec.z

#define MultVec2(_ret, _vec1, _vec2)         _ret.x = _vec1.x * _vec2.x; \
                                             _ret.y = _vec1.y * _vec2.y; \
                                             _ret.z = _vec1.z * _vec2.z

#define DivVec(_ret, _vec)                   _ret.x /= _vec.x; \
                                             _ret.y /= _vec.y; \
                                             _ret.z /= _vec.z

#define InFrontX(_k, _d)                     (RemotePos(_k) + <_d, 0.0, 0.0> * RemoteRot(_k) )
#define InFrontXThisRoot(_d)                 (llGetRootPosition() + <_d, 0.0, 0.0> * llGetRootRotation() )
#define InFrontY(_k, _d)                     (RemotePos(_k) + <0.0, _d, 0.0> * RemoteRot(_k) )
#define InFrontZ(_k, _d)                     (RemotePos(_k) + <0.0, 0.0, _d> * RemoteRot(_k) )
#define InFrontXVecR(_v, _d)                 ( (_v) + <_d, 0.0, 0.0> * llGetRootRotation() )
#define InFrontXVecRr(_v, _d, _r)            ( (_v) + <_d, 0.0, 0.0> * (_r) )
#define InFrontYVecRr(_v, _d, _r)            ( (_v) + <0.0, _d, 0.0> * (_r) )


#define PrimPercentUsed(_v)                  ((float)llGetParcelPrimCount(_v, PARCEL_COUNT_TOTAL, FALSE) * 100.0 / (float)llGetParcelMaxPrims(_v, FALSE))
#define PrimsFree(_v)                        (llGetParcelMaxPrims(_v, FALSE) - llGetParcelPrimCount(_v, PARCEL_COUNT_TOTAL, FALSE))


#define SoundTPout                           llPlaySound("d7a9a565-a013-2a69-797d-5332baa1a947", 1.0)

#ifdef _NO_INLINE_SoundAlert
string _SoundAlert = "ed124764-705d-d497-167a-182cd9fa2e6c";
#define SoundAlert                           llPlaySound(_SoundAlert, 1.0);
#else
#define SoundAlert                           llPlaySound("ed124764-705d-d497-167a-182cd9fa2e6c", 1.0)
#endif

#define SoundRezzing                         llPlaySound("3c8fc726-1fd6-862d-fa01-16c5b2568db6", 1.0)
#define SoundDelete                          llPlaySound("0cb7b00a-4c10-6948-84de-a93c09af2ba9", 1.0)
#define SoundTyping                          llPlaySound("5e191c7b-8996-9ced-a177-b2ac32bfea06", 1.0)

#ifdef _NO_INLINE_SoundInvop
string _SoundInvop = "ed124764-705d-d497-167a-182cd9fa2e6c";
#define SoundInvop                           llPlaySound(_SoundInvop, 1.0);
#else
#define SoundInvop                           llPlaySound("4174f859-0d3d-c517-c424-72923dc21f65", 1.0)
#endif

#define SoundPing                            llPlaySound("971bc958-ea04-194f-a78a-12826264dae4", 1.0)


/* f4a0660f-5446-dea2-80b7-6482a082803c - sound for object creation */
/* 0cb7b00a-4c10-6948-84de-a93c09af2ba9 - sound for object deletion */
/* 3c8fc726-1fd6-862d-fa01-16c5b2568db6 - sound for object rezzing */
/* 2ca849ba-2885-4bc3-90ef-d4987a5b983a - sound for invalid keystroke */
/* 4c8c3c77-de8d-bde2-b9b8-32635e0fd4a6 - sound for mouse click */
/* 4c8c3c77-de8d-bde2-b9b8-32635e0fd4a6 - sound for mouse click release (same as for click) */
/* 219c5d93-6c09-31c5-fb3f-c5fe7495c115 - sound for health reduction Female */
/* e057c244-5768-1056-c37e-1537454eeb62 - sound for health reduction Male */
/* 104974e3-dfda-428b-99ee-b0d4e748d3a3 - sound for money increase */
/* 77a018af-098e-c037-51a6-178f05877c6f - sound for money decrease */
/* 67cc2844-00f3-2b3c-b991-6418d01e1bb7 - sound for IM alert (ding ding) */
/* 3d09f582-3851-c0e0-f5ba-277ac5c73fb4 - sound for snapshot */

#ifndef INFORM_KB
#define INFORM_KB 1
#endif

#ifndef _MEMLIMIT
#define _MEMLIMIT                            61440
#endif
#define MFree                                (llGetUsedMemory() < _MEMLIMIT)

#if INFORM_KB
#define _FREEMEM                             (string)(llGetFreeMemory() >> 10) + "kB) $> "
#define _USEDMEM                             (string)(-(llGetUsedMemory() >> 10) ) + "kB) $> "
#define _AVMEM                               (string)( (_MEMLIMIT - llGetUsedMemory() ) >> 10) + "kB) ~> "
#else
#define _FREEMEM                             (string)llGetFreeMemory() + "): "
#define _USEDMEM                             (string)(-llGetUsedMemory() ) + ") $> "
#define _AVMEM                               (string)(_MEMLIMIT - llGetUsedMemory() ) + ") ~> "
#endif

#define tell(_msg)                           llSay(0, llGetScriptName() + " (" + _FREEMEM + _msg);
#define osay(_msg)                           llSay(0, "(" + _FREEMEM + _msg);
#define otell(_msg)                          llOwnerSay(llGetScriptName() + " (" + _FREEMEM + _msg);
#define ootell(_msg)                         llOwnerSay("(" + _FREEMEM + _msg);
#define footell(_msg)                        llOwnerSay("(" + _USEDMEM + _msg);

#ifdef _NO_INLINE_AFOOTELL
afootell(string _msg) {
  llOwnerSay("(" + _AVMEM + _msg);
}
#else
#define afootell(_msg)                       llOwnerSay("(" + _AVMEM + _msg)
#endif

#define arst(_k, _s)                         llRegionSayTo(_k, PUBLIC_CHANNEL, "(" + _AVMEM + _s)
#define fwis(_msg)                           llWhisper(PUBLIC_CHANNEL, "(" + _USEDMEM + _msg)
#define afwis(_msg)                          llWhisper(PUBLIC_CHANNEL, "(" + _AVMEM + _msg)
#define aftell(_msg)                         llSay(PUBLIC_CHANNEL, "(" + _AVMEM + _msg)
#define afshout(_msg)                        llShout(PUBLIC_CHANNEL, "(" + _AVMEM + _msg)

// something like printf()
#define fprintl(...)                         llDumpList2String(["(", (_MEMLIMIT - llGetUsedMemory() ) >> 10, "kB ) ~>", __VA_ARGS__], " ")
#define fprintlt(...)                        llDumpList2String(["(", (_MEMLIMIT - llGetUsedMemory() ) >> 10, "kB ) ~>", __VA_ARGS__], "|")
#define sprintl(...)                         llDumpList2String([__VA_ARGS__], " ")
#define sprintlt(...)                        llDumpList2String([__VA_ARGS__], "|")
#define stringifylt(_l)                      llDumpList2String(_l, "|")
#define apf(...)                             llSay(PUBLIC_CHANNEL, fprintl(__VA_ARGS__))
#define opf(...)                             llOwnerSay(fprintl(__VA_ARGS__))
#define parst(_k, ...)                       llRegionSayTo(_k, PUBLIC_CHANNEL, fprintl(__VA_ARGS__))
#define tarst(_k, ...)                       llRegionSayTo(_k, PUBLIC_CHANNEL, fprintlt(__VA_ARGS__))
#define starst(_k, ...)                      llRegionSayTo(_k, PUBLIC_CHANNEL, sprintlt(__VA_ARGS__))
#define imp(_k, ...)                         llInstantMessage(_k, sprintl(__VA_ARGS__))
#define impa(_k, ...)                        llInstantMessage(_k, fprintl(__VA_ARGS__))


#define IfAttached(_k)                       if( (_k != NULL_KEY) && llGetAttached() )

// durations
#define DAYLY                                86400
#define HOURLY                               3600
#define HOURLY_F                             3600.0
#define MINUTELY                             60


// constants
#define _STD_MAXDIALOGBUTTONS                12
#define _STD_MAXDIALOGTITLELEN               511
#define _STD_RLVCHANNEL                      -1812221819
#define _STD_LOCKMEISTERCHANNEL              -8888
#define _STD_LOCKGARBAGECHANNEL              -9119
//#define _STD_ILLEGALPOS                      <-50000.0, -50000.0, -50000.0>
#define _STD_MAXINT                          2147483647
#define _STD_MININT                          −2147483648
#define _STD_MINFLOAT                        1.175494351E-38
#define _STD_MAXFLOAT                        3.402823466E+38
#define _STD_KEYLENGTH                       36
#define _STD__CONST_e                        2.71828182845904523536
#define _STD_PROTMESSAGELEN                  7  // 0 -- 8


// timestamps: 2014-01-20T00:28:21.383008Z
#define _STD_TS_DATE   llGetSubString(llGetTimestamp(), 0, llSubStringIndex(llGetTimestamp(), "T") - 1)
#define _STD_TS_TIMEL  llGetSubString(llGetTimestamp(), llSubStringIndex(llGetTimestamp(), "T") + 1, llSubStringIndex(llGetTimestamp(), "Z") - 1)
#define _STD_TS_TIMES  llGetSubString(llGetTimestamp(), llSubStringIndex(llGetTimestamp(), "T") + 1, llSubStringIndex(llGetTimestamp(), ".") - 1)
#define _STD_TS_TIMESS llGetSubString(llGetTimestamp(), llSubStringIndex(llGetTimestamp(), "T") + 1, llSubStringIndex(llGetTimestamp(), "T") + 5)

#define _STD_TS_FULL                         StrX(StrX(StrX(llGetTimestamp(), "-", "/"), "T", " "), "Z", "")

#if TS_LONG_TIMESTAMPS
#define TS_TIME TS_TIMEL
#else
#define TS_TIME TS_TIMES
#endif

#ifdef _STD_DEBUG_PUBLIC
#ifdef _STD_DEBUG_USE_TIME
#define DEBUGmsg(...)                   llSay(PUBLIC_CHANNEL, fprintl(_STD_TS_FULL, __VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#define ERRORmsg(...)                   llSay(PUBLIC_CHANNEL, fprintl("err:", __VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#else
#define DEBUGmsg(...)                   llSay(PUBLIC_CHANNEL, fprintl(__VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#define ERRORmsg(...)                   DEBUGmsg("err:", __VA_ARGS__)
#endif
#else
#ifdef _STD_DEBUG_USE_TIME
#define DEBUGmsg(...)                   llOwnerSay(fprintl(_STD_TS_FULL, __VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#define ERRORmsg(...)                   llOwnerSay(fprintl("err:", __VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#else
#define DEBUGmsg(...)                   llOwnerSay(fprintl(__VA_ARGS__, "{", __FILE__, ":", __LINE__, "}"))
#define ERRORmsg(...)                   DEBUGmsg("err:", __VA_ARGS__)
#endif
#endif

// debug messages
#if DEBUG0
#define DEBUGmsg0(...)                  DEBUGmsg(__VA_ARGS__)
#else
#define DEBUGmsg0(...)
#endif

// debug messages level 1
#if DEBUG1
#define DEBUGmsg1(...)                  DEBUGmsg(__VA_ARGS__)
#else
#define DEBUGmsg1(...)
#endif

// debug messages level 2
#if DEBUG2
#define DEBUGmsg2(...)                  DEBUGmsg(__VA_ARGS__)
#else
#define DEBUGmsg2(...)
#endif

// debug messages level 3
#if DEBUG3
#define DEBUGmsg3(...)                  DEBUGmsg(__VA_ARGS__)
#else
#define DEBUGmsg3(...)
#endif

// debug messages from libraries
#if DEBUG_LIB
#define DEBUGmsgLIB(...)                DEBUGmsg(__VA_ARGS__)
#else
#define DEBUGmsgLIB(...)
#endif


#ifdef DEBUG_tellmem
#define DEBUG_TellMemory(_msg)						\
	DEBUGmsg(_msg);							\
	afootell("free: " + (string)llGetFreeMemory() + " of " + (string)llGetMemoryLimit()); \
	afootell("used: " + (string)llGetUsedMemory());			\
	afootell("gacl: " + (string)(llGetMemoryLimit() - llGetFreeMemory() - llGetUsedMemory()))
#else
#define DEBUG_TellMemory(...)
#endif


// permissions
#define ObjIsCopy4Owner                 (!!(llGetObjectPermMask(MASK_OWNER) & PERM_COPY) )
#define InvIsCopy4Owner(_which)         (!!(llGetInventoryPermMask(_which, MASK_OWNER) & PERM_COPY) )


//
#define NoText                          llSetText("", ZERO_VECTOR, 0.0)



#define NoPin                           llSetRemoteScriptAccessPin(0)


// shortcuts
#define SLPPF                           llSetLinkPrimitiveParamsFast
#define GLPP                            llGetLinkPrimitiveParams
#define GLOW(_ln, _fi)                  SLPPF(_ln, [PRIM_GLOW, ALL_SIDES, _fi])


// ideosyncracies
#define Select_ffb(_fvalA, _fvalB, _bcond)   ((_fvalA) * (float)(_bcond) + (_fvalB) * (float)(!(_bcond)))
#define const
#define void
#define event
#define when                            if
#define unless(_cond)                   if(!(_cond))

#define LoopDown(_idx, _do)             while(_idx) { --_idx; _do; }
#define LoopUp(_idx, _max, _do)         while(_idx < _max) { _do; ++_idx; }
#define foreach(_l, _do)                { int $_ = Len(_l); while($_) { --$_; _do; } }

#define until(_cond)                    while(!(_cond))

#define IfMessage(_what)                if(_what == _MESSAGE)
#define ProtocolID(_s)                  (Begstr(_MESSAGE, _STD_PROTMESSAGELEN) == _s)
#define ProtocolSimpleData              Endstr(_MESSAGE, 8)  // (_STD_PROTMESSAGELEN) + 1
#define ProtocolData(_s)                llParseString2List(_MESSAGE, [_s], [])  // _s is the separator
#define continue                        jump


//
#define TruncateDialogButton(_b)        llBase64ToString(Substr(llStringToBase64(_b), 0, 31))
#define TruncateDialogList(_idx, _list) LoopDown(_idx, _list = llListReplaceList(_list, (list)TruncateDialogButton(llList2String(_list, _idx)), _idx, _idx))


//#define _MY_UUID                        ( (key)("2c75aa8f-8780-4bbd-a5c1-75e773802284") )
#define _MY_UUID                        "2c75aa8f-8780-4bbd-a5c1-75e773802284"
#define _MY_NAME                        "Ratany Resident"


#endif // _LSLSTDDEF
