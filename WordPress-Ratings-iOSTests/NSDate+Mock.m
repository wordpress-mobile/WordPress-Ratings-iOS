#import "NSDate+Mock.h"
#import "JRSwizzle.h"


@implementation NSDate (NSDateMock)

static NSDate *_mockDate;

+ (void)swizzleMock
{
    [NSDate jr_swizzleClassMethod:@selector(date) withClassMethod:@selector(mockCurrentDate) error:nil];
}

+ (NSDate *)mockCurrentDate
{
    return _mockDate ?: [self mockCurrentDate];
}

+ (void)setMockDate:(NSDate *)mockDate
{
    _mockDate = mockDate;
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
}

@end
