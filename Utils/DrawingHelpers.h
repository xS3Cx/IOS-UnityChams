#pragma once
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

namespace DrawingHelpers {
    UIImage* CreateUIImageFromMTLTexture(id<MTLTexture> texture);
}
