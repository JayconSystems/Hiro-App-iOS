//
//  ITSuperViewController.h
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextfieldScrollViewController.h"

@interface SuperViewController : UITextfieldScrollViewController

-(UIFont *) getFontByName:(NSString *) fontName andSize : (CGFloat) size;
-(int)getIndexFromArrayValue:(NSArray *)arrValue withValue:(NSString *)strValue;
-(int)getIndexFromArrayValue:(NSArray *)arrValue withIntValue:(int)intValue;

@end
