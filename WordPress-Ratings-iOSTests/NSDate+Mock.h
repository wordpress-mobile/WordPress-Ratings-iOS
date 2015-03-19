//
//  NSDate+Mock.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/17/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDateMock)

+ (void)swizzleMock;
+ (void)setMockDate:(NSDate *)mockDate;
+ (NSDate *)mockCurrentDate;

- (NSDate *)dateByAddingDays:(NSInteger)days;

@end
