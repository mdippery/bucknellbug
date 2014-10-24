/*
 * Copyright (c) 2006-2011 Michael Dippery <michael@monkey-robot.com>
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

#import "BBDataFile.h"

#import "CSVFile.h"
#import "NSDate+Relative.h"
#import "NSString+Numeric.h"

#define SECONDS_IN_AN_HOUR  (60 * 60)

typedef enum {
    BBYearIndex        = 2-1,
    BBDateIndex        = 3-1,
    BBTimeIndex        = 4-1,
    BBPressureIndex    = 8-1,
    BBTemperatureIndex = 13-1,
    BBHumidityIndex    = 17-1,
    BBRainfallIndex    = 19-1
} BBDataFileIndex;

@interface BBDataFile (Private)
+ (NSDateFormatter *)dateFormatter;
- (void)resetData;
- (int)timestampOffset;
- (NSDate *)unmodifiedDate;
- (NSString *)dateString;
@end

@implementation BBDataFile

+ (NSURL *)defaultURL
{
    static NSURL *defaultURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBWeatherDataURL"];
        defaultURL = [[NSURL alloc] initWithString:url];
        NSLog(@"Loaded weather data URL: %@", defaultURL);
    });
    return defaultURL;
}

+ (NSStringEncoding)defaultEncoding
{
    return NSWindowsCP1251StringEncoding;
}

+ (NSTimeZone *)defaultTimeZone
{
    return [NSTimeZone timeZoneWithName:@"US/Eastern"];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        [sharedFormatter setDateFormat:@"yyyy/MM/dd HHmm"];
        [sharedFormatter setTimeZone:[BBDataFile defaultTimeZone]];
    });
    return sharedFormatter;
}

- (id)init
{
    if ((self = [super init])) {
        data = nil;
    }        
    return self;
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (data = %@)", [self class], self, data];
}

- (void)resetData
{
    [data release];
    data = [[CSVFile alloc] initWithContentsOfURL:[BBDataFile defaultURL] encoding:[BBDataFile defaultEncoding]];
}

- (void)updateWithSuccess:(BBWeatherServiceSuccessHandler)success failure:(BBWeatherServiceFailureHandler)failure
{
    // For parse documentation, see
    // http://www.departments.bucknell.edu/geography/Weather/output.htm
    // http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat

    NSDate *lastDate = [[[self date] retain] autorelease];
    [self resetData];
    if (data && [[self date] isAfter:lastDate]) {
        success();
    } else {
        failure();
    }
}

- (NSDate *)date
{
    return [[BBDataFile dateFormatter] dateFromString:[self dateString]];
}

- (NSString *)dateString
{
    NSString *year = [data objectAtIndex:BBYearIndex];
    NSString *date = [data objectAtIndex:BBDateIndex];
    NSString *time = [data objectAtIndex:BBTimeIndex];
    if (year && date && time) {
        return [NSString stringWithFormat:@"%@/%@ %@%@", year, date, [time length] == 3 ? @"0" : @"", time];
    } else {
        return nil;
    }
}

- (double)temperature
{
    return [[data objectAtIndex:BBTemperatureIndex] doubleValue];
}

- (double)humidity
{
    return [[data objectAtIndex:BBHumidityIndex] doubleValue];
}

- (unsigned int)pressure
{
    return [[data objectAtIndex:BBPressureIndex] unsignedIntValue];
}

- (unsigned int)rainfall
{
    return [[data objectAtIndex:BBRainfallIndex] unsignedIntValue];
}

@end
