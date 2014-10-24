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
#import "AFNetworking.h"


@interface BBDarkSkyService ()
- (NSURLRequest *)APIRequest;
@end


@implementation BBDarkSkyService

+ (NSString *)defaultURL
{
    static NSString *defaultURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultURL = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBDarkSkyURL"] retain];
        NSLog(@"Loaded base weather data URL: %@", defaultURL);
    });
    return defaultURL;
}

+ (CLLocationCoordinate2D)defaultLocation
{
    static CLLocationCoordinate2D defaultLocation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSNumber *lat = [info objectForKey:@"BBWeatherLatitude"];
        NSNumber *lon = [info objectForKey:@"BBWeatherLongitude"];
        defaultLocation = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        NSLog(@"Loaded weather data for location: %.4f,%.4f", defaultLocation.latitude, defaultLocation.longitude);
    });
    return defaultLocation;
}

- (id)init
{
    if ((self = [super init])) {
        _cache = nil;
    }
    return self;
}

- (void)dealloc
{
    [_cache release];
    [super dealloc];
}

- (void)updateWithSuccess:(BBWeatherServiceSuccessHandler)success failure:(BBWeatherServiceFailureHandler)failure
{
    [_cache release];
    AFJSONRequestOperation *req = [AFJSONRequestOperation JSONRequestOperationWithRequest:[self APIRequest] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Retrieved response: %@", JSON);
        if (![JSON isKindOfClass:[NSDictionary class]]) {
            NSLog(@"JSON response is not a dictionary");
            failure();
        }
        _cache = [JSON retain];
        success();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"HTTP request failed: %@", [error localizedDescription]);
        failure();
    }];
    [req start];
}

- (NSURLRequest *)APIRequest
{
    NSString *baseURL = [[self class] defaultURL];
    CLLocationCoordinate2D coords = [[self class] defaultLocation];
    NSString *requestURL = [NSString stringWithFormat:baseURL, DARK_SKY_API_KEY, coords.latitude, coords.longitude];
    NSURL *url = [NSURL URLWithString:requestURL];
    return [NSURLRequest requestWithURL:url];
}

@end
