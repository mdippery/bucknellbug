#import "TestReachability.h"
#import "MDReachability.h"

#define BAD_HOSTNAME    @"www.example.mil"
#define GOOD_HOSTNAME   @"www.bucknell.edu"


@implementation TestReachability

- (void)setUp
{
    [super setUp];
    badReachability = [[MDReachability alloc] initWithHostname:@"www.example.mil"];
    goodReachability = [[MDReachability alloc] initWithHostname:@"www.bucknell.edu"];
}

- (void)testInit
{
    STAssertNotNil(badReachability, @"Could not create MDReachability instance with hostname 'www.example.mil'.");
    STAssertNotNil(goodReachability, @"Could not create MDReachability instance with hostname 'www.bucknell.edu'.");
}

- (void)testIsReachable
{
    STAssertFalse([badReachability isReachable], @"'www.example.mil' is reachable, but shouldn't be.");
    STAssertTrue([goodReachability isReachable], @"'www.bucknell.edu' is not reachable, but should be.");
}

- (void)tearDown
{
    [badReachability release]; badReachability = nil;
    [goodReachability release]; goodReachability = nil;
    [super tearDown];
}

@end
