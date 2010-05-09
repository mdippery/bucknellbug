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

#import "CSVParser.h"


@implementation CSVParser

- (id)initWithContentsOfString:(NSString *)s
{
    if ((self = [super init])) {
        data = [[s componentsSeparatedByString:@","] retain];
    }
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc
{
    return [self initWithContentsOfString:[NSString stringWithContentsOfURL:url encoding:enc error:NULL]];
}

- (void)dealloc
{
    [data release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (%@)", [self class], self, [data componentsJoinedByString:@","]];
}

- (NSString *)objectAtIndex:(unsigned int)i
{
    return data ? [data objectAtIndex:i] : nil;
}

- (unsigned int)count
{
    return data ? [data count] : 0U;
}

@end
