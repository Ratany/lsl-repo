
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

//
// This file goes along with rfedip.h.  While rfedip.h provides
// defines for the rfedip protocol itself, this file provieds defines
// for tokens used by particular devices.  Tokens for control messages
// of the protocol are defined in rfedip.h.
//
// Possible parameters to tokens defined here should also be defined
// here.
//

#ifndef _RFEDIP_DEVICES
#define _RFEDIP_DEVICES


//
// tokens for tethering and chaining devices
//


// protTETHER is used to query a device for points to which a
// chain/rope/leash can be attached
//
// for example:
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protTETHER);
//
#define protTETHER                 "tether"

// protTETHER_RESPONSE is the answer to protTETHER in the form:
//
// for example:
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protTETHER_RESPONSE, kHookKey(n));
//
#define protTETHER_RESPONSE        "tether point"


// protDEVTYPE_QUERY0 is used to query devices for their type
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protDEVTYPE0_QUERY);
//
#define protDEVTYPE0_QUERY         "qry-devtype0"

// protDEVTYPE0_FLAGS is used to answer queries for the type of the device
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protDEVTYPE0_FLAGS, <flags of device>);
//
#define protDEVTYPE0_FLAGS         "devtype0-flags"

// Parameters for protDEVTYPE responses:
//
// This is a bit field, with the corresponding bit set when the device
// falls into the category and unset when not.  The bitfield is stored
// in an integer and transferred as an integer cast to a string.
//
// example for a piece of furniture that has moving parts:
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protDEVTYPE0_FLAGS, RFEDIP_FLAG_DEVTYPE0_FURNITURE + RFEDIP_FLAG_DEVTYPE0_MOVINGPARTS);
//
#define RFEDIP_FLAG_DEVTYPE0_UNDETERMINED   0  // the device is of no particular type
#define RFEDIP_FLAG_DEVTYPE0_FURNITURE      1  // furniture
#define RFEDIP_FLAG_DEVTYPE0_MOVING         2  // the device can move
#define RFEDIP_FLAG_DEVTYPE0_VEHICLE        4  // the device is a vehicle
#define RFEDIP_FLAG_DEVTYPE0_ATTACHMENT     8  // the device is intended to be worn as an attachment
#define RFEDIP_FLAG_DEVTYPE0_MOVINGPARTS   16  // the device has moving parts, or the part reported can move
#define RFEDIP_FLAG_DEVTYPE0_STATIONARY    32  // the device is stationary, like a building part, including doors
//
// Note: Attachments can be considered as moving because agents
//       wearing them are usually not stationary.  Attachments do not
//       need not be flagged as "moving".  When an attachment is a
//       vehicle, it should be flagged as moving.  Vehicles should
//       always be flagged as moving.  In any case, the paradigm for
//       the flags is the functionality of devices and, if in doubt,
//       should take precedence.
//
//       These device flags reported by a device should not
//       change. Use something like protDEVPROPS0 and appropriate
//       flags with it to report device properties.

// convert this back like:
//
#define RFEDIP_DeviceIsFurniture(_l)    (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_FURNITURE)
#define RFEDIP_DeviceIsMoving(_l)       (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_MOVING)
#define RFEDIP_DeviceIsVehicle(_l)      (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_VEHICLE)
#define RFEDIP_DeviceIsAttachment(_l)   (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_ATTACHMENT)
#define RFEDIP_DeviceIsMovingParts(_l)  (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_MOVINGPARTS)
#define RFEDIP_DeviceIsStationary(_l)   (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVTYPE0_STATIONARY)


// protDEVPROPS0 is used to query devices for their properties
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protDEVPROPS0_QUERY);
//
#define protDEVPROPS0_QUERY        "qry-devprops0"

// protDEVPROPS0_FLAGS is used to answer queries for the properties of the device
//
// RFEDIP_RESPOND(other_device, kThisDevice, RFEDIP_CHANNEL, protDEVPROPS0_FLAGS, <flag 1> + <flag 2>);
//
#define protDEVPROPS0_FLAGS        "devprops0-flags"

// define property flags here ... same method as with device types
//
#define RFEDIP_FLAG_DEVPROP0_UNDETERMINED    0  // the devices´ properties are undetermined
#define RFEDIP_FLAG_DEVPROP0_MOVING          1  // the device is currently moving

//
#define RFEDIP_DeviceDoesMove(_l)       (llList2Integer(_l, RFEDIP_idxPARAM1) & RFEDIP_FLAG_DEVPROP0_MOVING)


#endif  // _RFEDIP_DEVICES
