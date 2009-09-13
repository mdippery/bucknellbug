/*
 * MDPowerNotifications.c
 * Copyright (C) 2006-2009 Michael Dippery <mdippery@gmail.com>
 *
 * Redistribution and use of this software in source and binary forms, with or
 * without modification, are permitted provided that the following conditions
 * are met:
 *
 *   - Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   - Neither the name of the author nor the names of its contributors may be
 *     used to endorse or promote products derived from this software without
 *     specific prior written permission.
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

#include "MDPowerNotifications.h"

#include <stdbool.h>                 /* bool type */
#include <stdio.h>                   /* fprintf() */
#include <IOKit/IOKitLib.h>          /* IOServiceInterestCallback protocol */
#include <IOKit/IOMessage.h>         /* Message constants (for callback function) */
#include <IOKit/pwr_mgt/IOPMLib.h>   /* IORegisterForSystemPower() */

/***** Module constants *****/
CFStringRef const kMDComputerDidWakeNotification = CFSTR("Computer Did Wake Up");

/***** Static variables *****/
static bool registered = false;
static io_connect_t root_port;

/*
 * This function conforms to the IOServiceInterestCallback protocol as defined in
 * <IOKit/IOKitLib.h>. See Apple's documentation for more details.
 */
static void
pwr_callback(void *refcon, io_service_t service, natural_t msg_type, void *msg_arg)
{
	if (msg_type == kIOMessageSystemHasPoweredOn) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(),
											 kMDComputerDidWakeNotification,
											 NULL,
											 NULL,
											 false);
	} else if (msg_type == kIOMessageCanSystemSleep || msg_type == kIOMessageSystemWillSleep) {
		/* If this is not implemented, there is a 30-second delay before sleep. */
		IOAllowPowerChange(root_port, (long) msg_arg);
	}
}


void
MDRegisterForPowerNotifications(void)
{
	IONotificationPortRef notify;   /* Taken from Apple's documentation. */
	io_object_t iterator;           /* Taken from Apple's documentation. */
	
	if (registered) {
		fprintf(stderr, "MDPowerNotifications: Already registered for power notifications, aborting");
		return;
	}
	
	registered = true;
	root_port = IORegisterForSystemPower(NULL, &notify, pwr_callback, &iterator);
	if (!root_port) {
		fprintf(stderr, "MDPowerNotifications: IORegisterForSystemPower() failed");
		return;
	}
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notify), kCFRunLoopDefaultMode);
}
