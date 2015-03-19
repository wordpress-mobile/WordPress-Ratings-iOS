#import "NSDate+Ratings.h"


@implementation NSDate (Ratings)

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate = nil;
    NSDate *toDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:nil forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:nil forDate:toDateTime];
    
    NSDateComponents *delta = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return delta.day;
}

@end
