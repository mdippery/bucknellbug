#import "TestMenuItemAdditions.h"
#import "NSMenuItem+BucknellBug.h"


@implementation TestMenuItemAdditions

- (void)setUp
{
    defaultItem = [[NSMenuItem alloc] initWithTitle:@"Title: Old Title" action:NULL keyEquivalent:@""];
}

- (void)testUpdateTitle
{
    [defaultItem updateTitle:@"New Title"];
    STAssertEqualObjects([defaultItem title], @"Title: New Title", @"Item title is %@, not 'Title: New Title'.", [defaultItem title]);
}

- (void)tearDown
{
    [defaultItem release]; defaultItem = nil;
}

@end
