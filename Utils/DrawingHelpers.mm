#import "DrawingHelpers.h"

namespace DrawingHelpers {
    UIImage* CreateUIImageFromMTLTexture(id<MTLTexture> texture) {
        if (!texture) return nil;
        
        uint32_t width = (uint32_t)texture.width;
        uint32_t height = (uint32_t)texture.height;
        uint32_t rowBytes = width * 4;
        
        void *p = malloc(width * height * 4);
        [texture getBytes:p bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef contextRef = CGBitmapContextCreate(p, width, height, 8, rowBytes, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        CGContextRelease(contextRef);
        CGColorSpaceRelease(colorSpace);
        free(p);
        
        return image;
    }
}
