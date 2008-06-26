/*
 * MDPowerNotifications.h
 * Copyright (c) 2006-2007 Michael Dippery <mdippery@bucknell.edu>
 * All rights reserved.
 *
 * Redistribution and use of this software in source and binary forms, with or
 * without modification, are permitted provided that the following conditions are
 * met:
 *
 *   - Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   - Neither the name of Mario nor the names of its contributors may be used
 *     to endorse or promote products derived from this software without specific
 *     prior written permission of Michael Dippery.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @file MDPowerNotifications.h
 * Communicates with the subsystem to receive information about power-related
 * events, such as wakeup. This functionality is implemented in C, and links
 * against CoreFoundation and IOKit.
 *
 * Originally this file was an integral part of BucknellBug, but it has since been
 * modified to be a stand-alone module so that it can easily be moved to other
 * applications. It should be distributable to other apps without modification.
 */

#ifndef MD_POWER_NOTIFICATIONS_H
#define MD_POWER_NOTIFICATIONS_H

#include <CoreFoundation/CoreFoundation.h>


/**
 * @defgroup power Power Notifications
 * @{
 */

/** Name of the power notification posted upon machine wake. */
extern CFStringRef const kMDComputerDidWakeNotification;

/** @} */


/**
 * Registers an application to receive power management events. When the machine
 * wakes up, the notification @c BBComputerDidWakeNotification is posted to the
 * notification center.
 *
 * @see http://developer.apple.com/documentation/DeviceDrivers/Conceptual/IOKitFundamentals/PowerMgmt/chapter_10_section_3.html#//apple_ref/doc/uid/TP0000020-BAJIIDEB
 * @see http://developer.apple.com/qa/qa2004/qa1340.html
 */
void MDRegisterForPowerNotifications(void);

#endif
