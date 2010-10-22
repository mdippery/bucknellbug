/*
 * Copyright (c) 2010 Michael Dippery <mdippery@gmail.com>
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

#import "MDReachability.h"


@implementation MDReachability

+ (id)reachabilityWithHostname:(NSString *)aHostname
{
    return [[[self alloc] initWithHostname:aHostname] autorelease];
}

+ (id)reachabilityWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (id)initWithHostname:(NSString *)aHostname
{
    return [self initWithURL:[NSURL URLWithString:aHostname]];
}

- (id)initWithURL:(NSURL *)url
{
    if ((self = [super init])) {
        hostname = [url retain];
        netReachRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [[hostname absoluteString] UTF8String]);
    }
    return self;
}

- (void)dealloc
{
    if (netReachRef) CFRelease(netReachRef);
    [hostname release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (hostname = %@)", [self class], self, [hostname host]];
}

- (BOOL)isReachable
{
    // In 10.6+, NSURL has a method named
    // `checkResourceIsReachableAndReturnError:`. If
    // I ever switch to only supporting 10.6, I can
    // use this method instead.
    
    SCNetworkConnectionFlags netReachFlags;
    
    if (SCNetworkReachabilityGetFlags(netReachRef, &netReachFlags)) {
        return (netReachFlags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable;
    } else {
        NSLog(@"%s returned invalid flags", __FUNCTION__);
        return NO;
    }
}

@end
