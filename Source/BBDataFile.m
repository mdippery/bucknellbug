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

@interface BBDataFile ()
- (void)resetData;
- (NSString *)dateString;
@end

@implementation BBDataFile

- (id)init
{
    if ((self = [super init])) {
        _data = nil;

        NSString *url = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BBWeatherDataURL"];
        _defaultURL = [[NSURL alloc] initWithString:url];

        _defaultEncoding = NSWindowsCP1251StringEncoding;

        _defaultTimeZone = [NSTimeZone timeZoneWithName:@"US/Eastern"];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy/MM/dd HHmm"];
        [_dateFormatter setTimeZone:_defaultTimeZone];
    }        
    return self;
}

- (void)dealloc
{
    [_data release];
    [_defaultURL release];
    [_defaultTimeZone release];
    [_dateFormatter release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (data = %@)", [self class], self, _data];
}

- (void)resetData
{
    [_data release];
    _data = [[CSVFile alloc] initWithContentsOfURL:_defaultURL encoding:_defaultEncoding];
}

- (void)updateWithSuccess:(BBWeatherServiceSuccessHandler)success failure:(BBWeatherServiceFailureHandler)failure
{
    // For parse documentation, see
    // http://www.departments.bucknell.edu/geography/Weather/output.htm
    // http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat

    NSDate *lastDate = [[[self date] retain] autorelease];
    [self resetData];
    if (_data && [[self date] isAfter:lastDate]) {
        success();
    } else {
        failure();
    }
}

- (NSDate *)date
{
    return [_dateFormatter dateFromString:[self dateString]];
}

- (NSString *)dateString
{
    NSString *year = [_data objectAtIndex:BBYearIndex];
    NSString *date = [_data objectAtIndex:BBDateIndex];
    NSString *time = [_data objectAtIndex:BBTimeIndex];
    if (year && date && time) {
        return [NSString stringWithFormat:@"%@/%@ %@%@", year, date, [time length] == 3 ? @"0" : @"", time];
    } else {
        return nil;
    }
}

- (double)temperature
{
    return [[_data objectAtIndex:BBTemperatureIndex] doubleValue];
}

- (double)humidity
{
    return [[_data objectAtIndex:BBHumidityIndex] doubleValue];
}

- (NSUInteger)pressure
{
    return [[_data objectAtIndex:BBPressureIndex] unsignedIntValue];
}

- (double)rainfall
{
    return [[_data objectAtIndex:BBRainfallIndex] doubleValue];
}

@end
