//
//  NSString+Additions.h
//  Hiro
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)


- (NSString *)stringWithDigitsOnly;
- (NSString *)titleCasedString;
- (NSString *)uppercasedFirstString;
- (char *)UTF8CString;
- (BOOL)isValidEmail;
- (BOOL)isEqualToIgnoreCaseString:(NSString *)aString;
- (NSString *)trimData;
@end
