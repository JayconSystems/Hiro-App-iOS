#import "UIAlertViewWithBlocks.h"

void ShowUIAlert(UIAlertViewWithBlocks *alertView, BOOL shouldBuzz, void(^tapBlock)(NSInteger buttonTapped)) {
    alertView.delegate = alertView;
    alertView.block = tapBlock;
    if (shouldBuzz) {

    }
    [alertView show];
}

void ShowUIAlertWithOKButtonAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(void)) {
    UIAlertViewWithBlocks *alertView = [[UIAlertViewWithBlocks alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] ;
    ShowUIAlert(alertView, shouldBuzz, ^(NSInteger i) {
        if (nil != tapBlock) {
            tapBlock();
        }
    });
}

void ShowUIAlertWithYesNoButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(BOOL yes)) {
    ShowUIAlert([[UIAlertViewWithBlocks alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil], shouldBuzz, ^(NSInteger buttonTapped) {
        tapBlock(0 == buttonTapped);
    });
}

void ShowUIAlertWithDontShowOKButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(BOOL yes)) {
    ShowUIAlert([[UIAlertViewWithBlocks alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Don't Remind" otherButtonTitles:@"OK", nil] , shouldBuzz, ^(NSInteger buttonTapped) {
        tapBlock(0 == buttonTapped);
    });
}

void ShowUIAlertWithActionButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz,NSString *actionTitle,NSString *cancelTitle, void(^tapBlock)(BOOL yes)){
    ShowUIAlert([[UIAlertViewWithBlocks alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:actionTitle, nil] , shouldBuzz, ^(NSInteger buttonTapped) {
        tapBlock(1 == buttonTapped);
    });
}

void ShowUIAlertWithOKButton(NSString *title, NSString *message, BOOL shouldBuzz) {
    ShowUIAlertWithOKButtonAndTapBlock(title, message, shouldBuzz, nil);
}

@implementation UIAlertViewWithBlocks

@synthesize block;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (nil == self.block) {
        return;
    }
    
    self.block(buttonIndex);
}

- (void)dealloc {
    self.block = nil;
}

@end

