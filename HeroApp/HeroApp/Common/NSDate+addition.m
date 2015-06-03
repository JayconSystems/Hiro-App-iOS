//
//  NSDate+addition.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "NSDate+addition.h"

@implementation NSDate (addition)


- (NSString *)stringWithDateFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}
@end
