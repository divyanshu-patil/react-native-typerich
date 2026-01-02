//
//  InputTextView.m
//  ReactNativeTypeRich
//
//  Created by Div on 29/12/25.
//

#import "TypeRichUITextView.h"
#import "TypeRichTextInputView.h"

@implementation TypeRichUITextView

- (void)paste:(id)sender {
  UIPasteboard *pb = UIPasteboard.generalPasteboard;

  if ([self.owner isDisableImagePasting] &&
      pb.hasImages &&
      !pb.hasStrings) {
    return;
  }

  if (
    ![self.owner isDisableImagePasting]
    && pb.hasImages
  ) {
    
    UIImage *image = pb.image;
    if (!image) {
      [super paste:sender];
      return;
    }

    // NSData *data = UIImagePNGRepresentation(image); // when the requirement is for transparency enable this
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    
    if (!data) {
      return;
    }

    NSString *fileName =
      [NSString stringWithFormat:@"typerich_%@.png", NSUUID.UUID.UUIDString];

    NSString *path =
      [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];

    NSError *error = nil;
    if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
      return;
    }

    [self.owner emitPasteImageEventWith:path
                                      type:@"image/png"
                                  fileName:fileName
                                  fileSize:data.length];

    // Prevent attachment insertion
    return;
  }

  [super paste:sender];
}


- (BOOL)canPasteItemProviders:(NSArray<NSItemProvider *> *)itemProviders {
  for (NSItemProvider *provider in itemProviders) {
    if ([provider hasItemConformingToTypeIdentifier:@"public.text"]) {
        return YES;
      }

    if (![self.owner isDisableImagePasting] &&
        [provider hasItemConformingToTypeIdentifier:@"public.image"]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(paste:)) {
    UIPasteboard *pb = UIPasteboard.generalPasteboard;

    if (
      [self.owner isDisableImagePasting] &&
      pb.hasImages &&
      !pb.hasStrings) {
        return NO;
    }
    
    // Allow paste if there is text OR image
    if (pb.hasStrings || pb.hasImages) {
      return YES;
    }
    return NO;
  }

  return [super canPerformAction:action withSender:sender];
}

@end

