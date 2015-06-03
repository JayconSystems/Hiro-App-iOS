/*
 UITextfieldScrollViewController is a class that scroll texfields up the keyboard with animation, when keyboard is shown.
 Copyright (C) 2013 Michele Caldarone
 
 This file is part of UITextfieldScrollViewController.
 
 UITextfieldScrollViewController is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 UITextfieldScrollViewController is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with UITextfieldScrollViewController.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "UITextfieldScrollViewController.h"

@interface UITextfieldScrollViewController ()

@end

@implementation UITextfieldScrollViewController
{
    BOOL isKeyboardVisible;
    CGPoint activeTexfieldPosition;
    CGPoint lastScrollPoint;
    CGPoint originalScrollPoint;
    UIView* activeEditField;
    CGSize kbSize;
}

@synthesize scrollView, distanceFromKeyboard, scrollToPreviousPosition,MAX_LENGHT,InPutTextValid;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom initialization
    self.MAX_LENGHT = DEFAULT_TEXTFIELD_MAX_LENGHT;
    self.distanceFromKeyboard = DEFAULT_DISTACE_FROM_KEYBOARD;
    self.InPutTextValid = VALID_ANYTHING;
    self->isKeyboardVisible = NO;
    self.scrollToPreviousPosition = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [[self scrollView] addGestureRecognizer:singleTap];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self->activeEditField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // registering to keyboard notification
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // deregistering from keyboard notification
    [self deregisterFromKeyboardNotifications];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    self->isKeyboardVisible = YES;
    // getting the actvie textfield position relative to self.view
    CGFloat yTexfieldPosition = [self->activeEditField convertPoint:CGPointMake(0, 0) toView:self.view].y + self->activeEditField.frame.size.height;
    // adjustements relative to statusBar visibility
    if(![UIApplication sharedApplication].statusBarHidden)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            yTexfieldPosition += [UIApplication sharedApplication].statusBarFrame.size.width;
        }
        else
        {
            yTexfieldPosition += [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }
    // saving active textfield position
    self->activeTexfieldPosition = CGPointMake(self->activeTexfieldPosition.x, yTexfieldPosition);
    // saving scrollView content offset before it changes
    self->lastScrollPoint = self.scrollView.contentOffset;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = nil;
    if(aNotification)
    {
        info = [aNotification userInfo];
        kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    }
    // calculating area not covered by keyboard, relative to device orientation
    CGRect visibleArea = [[UIScreen mainScreen] bounds];
    
    // se in landscape, allora inverto width con height
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if(aNotification)
            kbSize = CGSizeMake(kbSize.height, kbSize.width);
        visibleArea = CGRectMake(visibleArea.origin.x, visibleArea.origin.y, visibleArea.size.height, visibleArea.size.width);
    }
    visibleArea = CGRectMake(0, 0, visibleArea.size.width, visibleArea.size.height - kbSize.height);
    // if visible area don't contains active texfield position, calculate the scroll offset useful to show active texfield, plus user custom distance specified in 'distanceFromKeyboard' property
    if (!CGRectContainsPoint(visibleArea, self->activeTexfieldPosition))
    {
        CGFloat yDeltaScroll = self->activeTexfieldPosition.y - visibleArea.size.height;
        CGPoint scrollPoint = CGPointMake(lastScrollPoint.x, lastScrollPoint.y + yDeltaScroll + self.distanceFromKeyboard);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self->isKeyboardVisible = NO;
    // setto vecchio punto di scroll
    if(self.scrollToPreviousPosition)
        [self.scrollView setContentOffset:self->originalScrollPoint animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)sender
{
    [self textInputDidBeginEditing:sender];
}

- (void)textViewDidBeginEditing:(UITextView *)sender
{
    [self textInputDidBeginEditing:sender];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.MAX_LENGHT == DEFAULT_TEXTFIELD_MAX_LENGHT) {
        if ([self.InPutTextValid isEqualToString:VALID_ANYTHING]) {
            return true;
        }else{
            NSCharacterSet *numberAndSpecialCharsSet = [[NSCharacterSet characterSetWithCharactersInString:self.InPutTextValid] invertedSet];
            return ([string rangeOfCharacterFromSet:numberAndSpecialCharsSet].location == NSNotFound);
        }
    }else{
        if ([self.InPutTextValid isEqualToString:VALID_ANYTHING] && string.length > 0) {
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            return !([newString length] > self.MAX_LENGHT);
        }else{
            NSCharacterSet *numberAndSpecialCharsSet = [[NSCharacterSet characterSetWithCharactersInString:self.InPutTextValid] invertedSet];
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            return (([string rangeOfCharacterFromSet:numberAndSpecialCharsSet].location == NSNotFound) && !([newString length] > self.MAX_LENGHT));
        }
    }
}

- (void)textInputDidBeginEditing:(UIView *)sender
{
    self->activeEditField = sender;
    if(self->isKeyboardVisible)
    {
        [self keyboardWillShow:nil];
        [self keyboardWasShown:nil];
    }
    else
    {
        self->originalScrollPoint = self.scrollView.contentOffset;
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{

}

@end
