/*
 * Copyright (c) 2006-2010 Michael Dippery <mdippery@gmail.com>
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
#import "CSVParser.h"
#import "NSDate+BucknellBug.h"

#define DATA_FILE_URL   [NSURL URLWithString:@"http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat"]
#define DATA_FILE_ENC   NSWindowsCP1251StringEncoding

typedef enum {
    IdxYear     = 2-1,
    IdxDate     = 3-1,
    IdxTime     = 4-1,
    IdxPressure = 8-1,
    IdxTemp     = 13-1,
    IdxHumidity = 17-1,
    IdxRainfall = 19-1
} DataFileIndex;

@implementation BBDataFile

- (id)init
{
    if ((self == [super init])) {
        data = [[CSVParser alloc] initWithContentsOfURL:DATA_FILE_URL encoding:DATA_FILE_ENC];
        if (!data) {
            [self autorelease];
            return nil;
        }
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
    return [NSString stringWithFormat:@"<%@ %p> (data = %@)", [self class], self, data];
}

- (BOOL)update
{
    // For parse documentation, see
    // http://www.departments.bucknell.edu/geography/Weather/output.htm
    // http://www.departments.bucknell.edu/geography/Weather/Data/raw_data.dat
    
    NSDate *lastDate = [[self date] retain];
    [data release];
    data = [[CSVParser alloc] initWithContentsOfURL:DATA_FILE_URL encoding:DATA_FILE_ENC];
    if (data == nil) return NO;
    return [[self date] isAfter:lastDate];
}

- (NSDate *)date
{
    NSString *yearStr = [data objectAtIndex:IdxYear];
    NSString *dateStr = [data objectAtIndex:IdxDate];
    NSString *timeStr = [data objectAtIndex:IdxTime];
    return [NSDate dateWithYear:yearStr month:[dateStr substringToIndex:2] day:[dateStr substringFromIndex:3] hour:timeStr];
}

- (double)temperature
{
    return [[data objectAtIndex:IdxTemp] doubleValue];
}

- (double)humidity
{
    return [[data objectAtIndex:IdxHumidity] doubleValue];
}

- (unsigned int)pressure
{
    return (unsigned int) [[data objectAtIndex:IdxPressure] intValue];
}

- (unsigned int)rainfall
{
    return (unsigned int) [[data objectAtIndex:IdxRainfall] intValue];
}

@end
