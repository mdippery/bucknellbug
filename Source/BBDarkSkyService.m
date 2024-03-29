/*
 * Copyright (c) 2014-2023 Michael Dippery <michael@monkey-robot.com>
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
#import "BBNestedObject.h"
#import "NSString+Numeric.h"


@interface BBDarkSkyService ()
- (NSURLRequest *)APIRequest;
@end


@implementation BBDarkSkyService

- (id)init
{
    if ((self = [super init])) {
        _cache = nil;

        _defaultURL = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBDarkSkyURL"] retain];

        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSNumber *lat = [info objectForKey:@"BBWeatherLatitude"];
        NSNumber *lon = [info objectForKey:@"BBWeatherLongitude"];
        _defaultLocation = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
    }
    return self;
}

- (void)dealloc
{
    [_cache release];
    [_defaultURL release];
    [super dealloc];
}

- (void)updateWithSuccess:(BBWeatherServiceSuccessHandler)success failure:(BBWeatherServiceFailureHandler)failure
{
    [_cache release];

    NSLog(@"Attempting to retrieve weather from %@", [[self APIRequest] URL]);
    NSURLSessionTask *req = [[NSURLSession sharedSession] dataTaskWithRequest:[self APIRequest] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"HTTP request failed: %@", [error localizedDescription]);
            failure();
        } else {
            NSError *e = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];

            if (e) {
                NSLog(@"Error reading JSON data: %@", [error localizedDescription]);
                failure();
            } else if (![json isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"JSON response is not a dictionary");
                    failure();
            } else {
                _cache = [json retain];
                success();
            }
        }
    }];

    [req resume];
}

- (NSURLRequest *)APIRequest
{
    NSString *requestURL = [NSString stringWithFormat:_defaultURL, DARK_SKY_API_KEY, _defaultLocation.latitude, _defaultLocation.longitude];
    NSURL *url = [NSURL URLWithString:requestURL];
    return [NSURLRequest requestWithURL:url];
}

- (NSDate *)date
{
    id dateObj = [_cache nestedObjectForKey:@"currently.time"];
    NSTimeInterval ts = [dateObj doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}

- (double)temperature
{
    id tempObj = [_cache nestedObjectForKey:@"currently.temperature"];
    return [tempObj doubleValue];
}

- (double)humidity
{
    id humidityObj = [_cache nestedObjectForKey:@"currently.humidity"];
    return [humidityObj doubleValue] * 100.0;
}

- (NSUInteger)pressure
{
    id pressureObj = [_cache nestedObjectForKey:@"currently.pressure"];
    // Actually comes back as a double, but for now convert it to unsigned int
    return [pressureObj unsignedIntegerValue];
}

- (double)rainfall
{
    id rainfallObj = [_cache nestedObjectForKey:@"daily.data.0.precipAccumulation"];
    if (!rainfallObj) return 0.0;
    return [rainfallObj doubleValue];
}

@end
