//
//  NSString+Additions.m
//  Hiro
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "NSString+Additions.h"
#import "RegexKitLite.h"

@implementation NSString (Additions)

- (char *)UTF8CString {
    return (char *)[self cStringUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)isEqualToIgnoreCaseString:(NSString *)aString
{
    return [[self lowercaseString] isEqualToString:[aString lowercaseString]];
}

- (BOOL)isValidEmail {
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    return [self isMatchedByRegex:emailRegEx];
}

- (NSString *)stringWithDigitsOnly {
    return [self stringByReplacingOccurrencesOfRegex:@"[^\\d]" withString:@""];
}

- (NSString *)titleCasedString {
    ZAssert([self length] > 0, @"string must have at least one character");
    return [self stringByReplacingOccurrencesOfRegex:@"\\b(\\w)" usingBlock:^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
        return  [NSString stringWithFormat:@"%@", [capturedStrings[1] capitalizedString]];
    }];
}

- (NSString *)uppercasedFirstString {
    ZAssert([self length] > 0, @"string must have at least one character");
    return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
}

- (NSString *)trimData{
    ZAssert([self length] > 0, @"string must have at least one character");
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}



@end
