#import <Foundation/Foundation.h>


@interface UIAlertViewWithBlocks : UIAlertView {
}

@property (nonatomic, copy) void(^block)(NSInteger);

@end



void ShowUIAlertWithOKButton(NSString *title, NSString *message, BOOL shouldBuzz);

void ShowUIAlertWithOKButtonAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(void));

void ShowUIAlertWithYesNoButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(BOOL yes));

void ShowUIAlertWithDontShowOKButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz, void(^tapBlock)(BOOL yes)) ;
void ShowUIAlertWithActionButtonsAndTapBlock(NSString *title, NSString *message, BOOL shouldBuzz,NSString *actionTitle,NSString *cancelTitle, void(^tapBlock)(BOOL yes));
void ShowUIAlert(UIAlertViewWithBlocks *alertView, BOOL shouldBuzz, void(^tapBlock)(NSInteger buttonTapped));
