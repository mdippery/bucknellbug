/*
 * Copyright (c) 2006-2009 Michael Dippery <mdippery@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file GrowlController.h
 * Provides definitions for the implementation of the @c BBGrowlController class.
 * Also provides a listing of most of the Growl notifications recognized by the
 * application.
 */

@protocol GrowlApplicationBridgeDelegate;

/**
 * @defgroup growl BucknellBug Growl Notifications
 * @{
 */

/// A notification that the weather has been updated.
extern NSString * const kBBGrowlWeatherUpdated;

/** @} */

/**
 * Describes an object that handles BucknellBug Growl notifications.
 * 
 * @see http://growl.info/documentation/developer/implementing-growl.php?lang=cocoa
 */
@interface GrowlController : NSObject <GrowlApplicationBridgeDelegate>

/**
 * Returns the application-wide shared instance of @c BBGrowlController. This
 * should be used instead of any <code>-[init...]</code> methods, because none
 * of those will work.
 *
 * @return The application-wide shared instance of @c BBGrowlController. */
+ (GrowlController *)sharedController;

/**
 * Registers the application with the Growl notification system.
 */
- (void)registerWithGrowl;

@end
