/*
 * Copyright (c) 2015 Michael Dippery <michael@monkey-robot.com>
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

#import "BBNestedObject.h"


@interface NSArray (NestedObjectPrivate)
- (id)objectForNestedKeyComponent:(NSString *)key;
@end


@interface NSDictionary (NestedObjectPrivate)
- (id)objectForNestedKeyComponent:(NSString *)key;
@end


id BBRetrieveNestedObjectUsingKeyArray(id obj, NSArray *keys)
{
    NSCAssert([keys count] >= 1, @"key count < 1");
    NSString *key = [keys objectAtIndex:0];
    id item = [obj objectForNestedKeyComponent:key];
    if ([keys count] > 1) {
        NSArray *rest = [keys subarrayWithRange:NSMakeRange(1, [keys count]-1)];
        return BBRetrieveNestedObjectUsingKeyArray(item, rest);
    } else {
        return item;
    }
}


id BBRetrieveNestedObject(id container, NSString *key)
{
    NSArray *keys = [key componentsSeparatedByString:@"."];
    NSCAssert([keys count] >= 1, @"key count < 1");
    return BBRetrieveNestedObjectUsingKeyArray(container, keys);
}


@implementation NSArray (NestedObject)

- (id)nestedObjectForKey:(NSString *)key
{
    return BBRetrieveNestedObject(self, key);
}

@end


@implementation NSDictionary (NestedObject)

- (id)nestedObjectForKey:(NSString *)key
{
    return BBRetrieveNestedObject(self, key);
}

@end

@implementation NSArray (NestedObjectPrivate)

- (id)objectForNestedKeyComponent:(NSString *)key
{
    return [self objectAtIndex:[key integerValue]];
}

@end

@implementation NSDictionary (NestedObjectPrivate)

- (id)objectForNestedKeyComponent:(NSString *)key
{
    return [self objectForKey:key];
}

@end
