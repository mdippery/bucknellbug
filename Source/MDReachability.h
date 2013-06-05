/*
 * Copyright (c) 2010 Michael Dippery <michael@monkey-robot.com>
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

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface MDReachability : NSObject
{
    NSURL *hostname;
    SCNetworkReachabilityRef netReachRef;
}

+ (id)reachabilityWithHostname:(NSString *)aHostname;
+ (id)reachabilityWithURL:(NSURL *)url;
- (id)initWithHostname:(NSString *)aHostname;
- (id)initWithURL:(NSURL *)url;
- (BOOL)isReachable;

@end
