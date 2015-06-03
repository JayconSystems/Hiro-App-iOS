//
//  NSArray+Statistics.m
//  Hero
//
//  Created by Jaycon Systems on 04/02/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "NSArray+Statistics.h"

@implementation NSArray (Statistics)
- (NSNumber *)sum {
    NSNumber *sum = [self valueForKeyPath:@"@sum.self"];
    return sum;
}

- (NSNumber *)mean {
    NSNumber *mean = [self valueForKeyPath:@"@avg.self"];
    return mean;
}

- (NSNumber *)min {
    NSNumber *min = [self valueForKeyPath:@"@min.self"];
    return min;
}

- (NSNumber *)max {
    NSNumber *max = [self valueForKeyPath:@"@max.self"];
    return max;
}

- (NSNumber *)median {
    NSArray *sortedArray = [self sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *median;
    if (sortedArray.count != 1) {
        if (sortedArray.count % 2 == 0) {
            median = @(([[sortedArray objectAtIndex:sortedArray.count / 2] intValue]) + ([[sortedArray objectAtIndex:sortedArray.count / 2 + 1] intValue]) / 2);
        }
        else {
            median = @([[sortedArray objectAtIndex:sortedArray.count / 2] intValue]);
        }
    }
    else {
        median = [sortedArray objectAtIndex:1];
    }
    return median;
}

- (NSNumber *)standardDeviation {
    NSNumber *sumOfDifferencesFromMean = [NSNumber numberWithInt:0];
    for (NSNumber *score in self) {
        sumOfDifferencesFromMean = [NSNumber numberWithInt:[sumOfDifferencesFromMean intValue]+[score intValue]];
    }
    
    NSNumber *standardDeviation = [NSNumber numberWithInt:[sumOfDifferencesFromMean intValue]/(int)self.count];
    return standardDeviation;
}


@end
