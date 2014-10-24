/*
 * Copyright (c) 2014 Michael Dippery <michael@monkey-robot.com>
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

#import "BBDarkSkyService.h"


@implementation BBDarkSkyService

+ (NSURL *)defaultURL
{
    static NSURL *defaultURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBDarkSkyURL"];
        defaultURL = [[NSURL alloc] initWithString:url];
        NSLog(@"Loaded weather data URL: %@", defaultURL);
    });
    return defaultURL;
}

+ (CLLocation *)defaultLocation
{
    static CLLocation *defaultLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSNumber *lat = [info objectForKey:@"BBWeatherLatitude"];
        NSNumber *lon = [info objectForKey:@"BBWeatherLongitude"];
        defaultLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        NSLog(@"Loaded weather data for location: %@", defaultLocation);
    });
    return defaultLocation;
}

- (id)init
{
    if ((self = [super init])) {
        _cache = nil;
        [self update];
    }
    return self;
}

- (void)dealloc
{
    [_cache release];
    [super dealloc];
}

- (BOOL)update
{
    [_cache release];
    // TODO: Fetch new data
    return NO;
}

@end
