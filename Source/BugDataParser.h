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
 * @file BugDataParser.h
 * Defines the @c MDDataFileParser class and associated pieces of data.
 */

#import <Cocoa/Cocoa.h>

/**
 * @defgroup weatherKeys Weather Data Keys
 * @{
 */

/// Contains the date, in seconds since the Unix epoch, that the data file was last successfully parsed.
extern NSString * const kMDKeyDate;
/// The temperature in degrees Fahrenheit.
extern NSString * const kMDKeyTemp;
/// The humidity, as a percentage.
extern NSString * const kMDKeyHumidity;
/// The sunshine index (the percentage of sun hitting the earth's surface), as a percentage.
extern NSString * const kMDKeySun;
/// The barometric pressure, in millibars.
extern NSString * const kMDKeyPressure;
/// The amount of rainfall, in inches, over the past twenty-four (24) hours.
extern NSString * const kMDKeyRainfall;

/** @} */

/** Enscapulates the Bucknell Weather Station weather feed. */
@interface BugDataParser : NSObject
{
	/// The URL of the data file.
	NSURL *dataFileURL;
	/// The date that the data file was last successfully parsed.
	NSDate *lastUpdate;
	/// A cache of the most recent data from the data file.
	NSMutableDictionary *dataCache;
}

/**
 * Creates a new instance with the data file at the specified URL.
 *
 * @param url The URL of the data file as an \c NSString object.
 *
 * @return A new instance of @c MDDataFileParser, or @c nil if the specified URL
 *   is invalid.
 */
- (id)initWithURL:(NSString *)url;

/** 
 * Parses the weather data feed, and returns the data from the feed in an
 * \c NSDictionary object. The keys of the dictionary are \c NSStrings, and
 * correspond to the keys defined in \c MDDataFileParser.h. The values of the
 * dictionary are \c NSNumber objects (including the date of the last update,
 * which is stored as the number of seconds since the Unix epoch).
 *
 * @param hasNewData Specifies weather the feed has new data since the last time it
 *   was successfully checked. @c hasNewData's value will be changed by the method.
 * 
 * @return An @c NSDictionary object containing the latest data. If the feed has never
 *   been successfully parsed, an empty @c NSDictionary, containing 0 objects, will be
 *   returned, and @c hasNewData will be set to @c NO.
 */
- (NSDictionary *)fetchWeatherData:(BOOL *)hasNewData;

/**
 * Returns the maximum size of the data dictionary returned by an instance of
 * \c MDDataFileParser.
 *
 * @note This is not necessarily the current size of the data cache; rather, this
 *   is a value beyond which the cache is guaranteed to not grow.
 *
 * @return The maximum size of the data dictionary.
 */
- (unsigned int)maxCount;

@end
