//
//  InputTextView.h
//  Pods
//
//  Created by Div on 29/12/25.
//

#import <UIKit/UIKit.h>

@class TypeRichTextInputView;

@interface TypeRichUITextView : UITextView
@property (nonatomic, weak) TypeRichTextInputView *owner;
@end
