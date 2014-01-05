
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


// defines for Ratany fine Engineerings Device Interface Protocol

#ifndef _RFEDIP
#define _RFEDIP

#define RFEDIP_sVERSION                           "RFEDIP-1.0"  // protocol version
#ifndef RFEDIP_sSUFFICIENT_VERSION
#define RFEDIP_sSUFFICIENT_VERSION                "RFEDIP"  // default to any version as sufficient version
#endif
#define RFEDIP_sSEP                               "|"  // separator used in protocol messages

#define RFEDIP_CHANNEL                            -20131224  // default channel used for protocol messages

#define RFEDIP_protIDENTIFY_QUERY                 "identify"  // identification query, must be responded to with RFEDIP_protIDENTIFY
#define RFEDIP_protIDENTIFY                       "identity"  // answer to identification queries
#define RFEDIP_protEND                            "msg_end!"  // indicate end of data transfer; if a particular channel was opened, this channel can be closed
#define RFEDIP_protOPEN                           "openchan"  // open a particular channel for further communication, mandatorily has a channel number as parameter

#define RFEDIP_ToSENDER(_l)                       llList2Key(_l, 0)  // return UUID of sender from list _l
#define RFEDIP_ToRCPT(_l)                         llList2Key(_l, 1)  // return UUID of recipient from list _l
#define RFEDIP_ToPROTVERSION(_l)                  llList2String(_l, 2) // return string containing the version of the protocol from list _l
#define RFEDIP_ToFirstTOKEN(_l)                   llList2String(_l, 3)  // return the first token from list _l
#define RFEDIP_ToFirstPARAM(_l)                   llList2String(_l, 4) // return the first parameter
#define RFEDIP_ToRESPONSE(_sndr, _rcpt, ...)      llDumpList2String([_sndr, _rcpt, RFEDIP_sVERSION, __VA_ARGS__], RFEDIP_sSEP)  // convert a protocol payload into a protocol message
#define REFDIP_OPEN(_rcpt, _sndr, _nchan)         llRegionSayTo(_rcpt, RFEDIP_CHANNEL, RFEDIP_ToRESPONSE(_sndr, _rcpt, RFEDIP_protOPEN, _nchan))  // open a particular channel for communication
#define RFEDIP_END(_rcpt, _sndr, _nchan)          llRegionSayTo(_rcpt, RFEDIP_CHANNEL, RFEDIP_ToRESPONSE(_sndr, _rcpt, RFEDIP_protEND, _nchan))  // indicate end of communication on channel _c
#define RFEDIP_IDQUERY                            llRegionSay(RFEDIP_CHANNEL, RFEDIP_protIDENTIFY_QUERY)  // ask all rfedip compliant devices to identify themselves
#define RFEDIP_RESPOND(_rcpt, _sndr, _chan, ...)  llRegionSayTo(_rcpt, _chan, RFEDIP_ToRESPONSE(_sndr, _rcpt, __VA_ARGS__))

#define RFEDIP_iMINMSGLEN                         4  // used to figure out whether a message is a RfE-dip message or not


#endif  // _RFEDIP
