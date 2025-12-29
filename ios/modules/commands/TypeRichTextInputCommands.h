//
//  TypeRichTextInputCommands.h
//  Pods
//
//  Created by Div on 29/12/25.
//

#import <UIKit/UIKit.h>
#import "TypeRichTextInputView.h"

@interface TypeRichTextInputCommands : NSObject
@property (nonatomic, strong) NSOperationQueue *commandQueue;

- (instancetype)initWithTextView:(UITextView *)textView
                           owner:(TypeRichTextInputView *)owner;

- (void)focus;
- (void)blur;
- (void)setText:(NSString *)text;
- (void)setSelectionStart:(NSInteger)start end:(NSInteger)end;
- (void)insertTextAtStart:(NSInteger)start
                      end:(NSInteger)end
                     text:(NSString *)text;
@end
