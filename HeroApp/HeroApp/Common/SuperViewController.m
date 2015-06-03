//
//  ITSuperViewController.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "SuperViewController.h"

@interface SuperViewController ()

@end

@implementation SuperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIFont *) getFontByName:(NSString *) fontName andSize : (CGFloat) size
{
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

-(int)getIndexFromArrayValue:(NSArray *)arrValue withValue:(NSString *)strValue
{
    if (arrValue && strValue) {
        
        for (int i = 0 ; i <arrValue.count; i++) {
            if ([arrValue[i] isKindOfClass:[NSString class]]) {
                if ([arrValue[i] isEqualToString:strValue]) {
                    return i;
                    break;
                }
            }
        }
    }
    return 0;
}

-(int)getIndexFromArrayValue:(NSArray *)arrValue withIntValue:(int)intValue
{
    if (arrValue) {
        
        for (int i = 0 ; i <arrValue.count; i++) {
            if ([arrValue[i] intValue]  == intValue) {
                return i;
                break;
            }
        }
    }
    return 0;
}

@end
