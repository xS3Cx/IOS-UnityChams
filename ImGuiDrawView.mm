#import "Esp/ImGuiDrawView.h"
#import "Init/IL2CPPInit.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include "IMGUI/imgui.h"
#include "IMGUI/imgui_internal.h"
#include "IMGUI/imgui_impl_metal.h"
#import "Resources/Fonts/IconsFontAwesome6.h"
#import "Resources/Fonts/IconsFontAwesome6_Bytes.h"
#import "Resources/Fonts/din_alternate.hpp"
#include "IMGUI/Il2cpp.h"
#include "IL2CPP/Hooks.h"
#include "Chams/ChamsManager.h"
#include "Utils/ImGuiHelpers.h"
#include "Utils/DrawingHelpers.h"
#include "UI/InitializationOverlay.h"
#include "UI/MainMenuWindow.h"
#include "Resources/Textures/Logo/LogoData.h"

@interface ImGuiMTKView : MTKView
@end

@implementation ImGuiMTKView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if (!subview.hidden && subview.userInteractionEnabled && [subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) {
            return YES;
        }
    }

    ImGuiContext* Context = ImGui::GetCurrentContext();
    if (Context) {
        const ImVector<ImGuiWindow*>& Windows = Context->Windows;
        for (int i = 0; i < Windows.Size; ++i) {
            ImGuiWindow* CurrentWindow = Windows[i];
            if (!CurrentWindow) continue;
            if (CurrentWindow->Active && !(CurrentWindow->Flags & ImGuiWindowFlags_NoInputs)) {
                CGRect touchableArea = CGRectMake(CurrentWindow->Pos.x, CurrentWindow->Pos.y, CurrentWindow->Size.x, CurrentWindow->Size.y);
                if (CGRectContainsPoint(touchableArea, point)) {
                    return [super pointInside:point withEvent:event];
                }
            }
        }
    }
    return NO;
}
@end

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) UIButton *toggleMenuButton;
@end

@implementation ImGuiDrawView

static bool MenDeal = true;
static float ui_scale = 0.70f;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();

    ImGuiHelpers::ApplyDefaultStyle();

    io.Fonts->AddFontFromMemoryCompressedTTF((void*)din_alternate_compressed_data, din_alternate_compressed_size, 18.0f, NULL, io.Fonts->GetGlyphRangesVietnamese());
    static const ImWchar icons_ranges[] = { ICON_MIN_FA, ICON_MAX_16_FA, 0 };
    ImFontConfig fa_config;
    fa_config.MergeMode = true;
    fa_config.PixelSnapH = true;
    fa_config.FontDataOwnedByAtlas = false;
    io.Fonts->AddFontFromMemoryCompressedTTF((void*)fa6_solid_compressed_data, fa6_solid_compressed_size, 16.0f, &fa_config, icons_ranges);

    ImGui_ImplMetal_Init(_device);
    return self;
}

+ (void)showChange:(BOOL)open {
    MenDeal = open;
}

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.view = [[ImGuiMTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
    self.mtkView.clipsToBounds = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [IL2CPPInit startPrecheck];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupToggleMenuButton];
    });
}

- (void)setupToggleMenuButton {
    if (self.toggleMenuButton) return;
    CGFloat btnSize = 25.0f;
    self.toggleMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleMenuButton.frame = CGRectMake(20, 100, btnSize, btnSize);
    self.toggleMenuButton.layer.cornerRadius = 8.0f;
    self.toggleMenuButton.backgroundColor = [UIColor colorWithRed:0.06f green:0.06f blue:0.06f alpha:0.85f];
    self.toggleMenuButton.layer.borderWidth = 2.0f;
    self.toggleMenuButton.layer.borderColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.28f alpha:1.0f].CGColor;
    self.toggleMenuButton.clipsToBounds = YES;

    id<MTLTexture> mtlLogo = (__bridge id<MTLTexture>)(void *)getLogoTexture();
    if (mtlLogo) {
        UIImage *logoImg = DrawingHelpers::CreateUIImageFromMTLTexture(mtlLogo);
        if (logoImg) {
            [self.toggleMenuButton setImage:logoImg forState:UIControlStateNormal];
            self.toggleMenuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.toggleMenuButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        }
    }

    [self.toggleMenuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.toggleMenuButton addGestureRecognizer:panGesture];
    [self.view addSubview:self.toggleMenuButton];
}

- (void)toggleMenu {
    MenDeal = !MenDeal;
    [self.view bringSubviewToFront:self.toggleMenuButton];
    self.toggleMenuButton.userInteractionEnabled = YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)pangesture {
    CGPoint translation = [pangesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(pangesture.view.center.x + translation.x, pangesture.view.center.y + translation.y);
    newCenter.x = MAX(pangesture.view.frame.size.width/2, MIN(self.view.frame.size.width - pangesture.view.frame.size.width/2, newCenter.x));
    newCenter.y = MAX(pangesture.view.frame.size.height/2, MIN(self.view.frame.size.height - pangesture.view.frame.size.height/2, newCenter.y));
    pangesture.view.center = newCenter;
    [pangesture setTranslation:CGPointZero inView:self.view];
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    // Required delegate method
}

- (void)updateImguiDisplayParameters:(MTKView *)view {
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);
    CGFloat scale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(scale, scale);
    NSInteger fps = view.preferredFramesPerSecond ?: 60;
    io.DeltaTime = 1.0f / (float)MAX(1, (int)fps);
}

- (void)prepareAndRenderImGui:(MTKView *)view encoder:(id<MTLRenderCommandEncoder>)encoder {
    ImGui_ImplMetal_NewFrame(view.currentRenderPassDescriptor);
    ImGui::NewFrame();

    [IL2CPPInit updateInitializationProgress];

    if ([IL2CPPInit isShowingInitOverlay] && ![IL2CPPInit isInitializationComplete]) {
        UI::DrawInitializationOverlay(view.bounds.size.width, view.bounds.size.height);
    }

    if (MenDeal && [IL2CPPInit isInitializationComplete]) {
        ImFont* font = ImGui::GetFont();
        if (font) font->Scale = ui_scale;
        
        CGFloat x = (view.bounds.size.width - 400) / 2;
        CGFloat y = (view.bounds.size.height - 300) / 2;
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);

        UI::DrawMainMenu(&MenDeal);
    }

    if (Chams::chams_enabled && Chams::current_shader_ptr) {
        Chams::ApplyDynamicChams();
    }

    ImGui::Render();
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), [self.commandQueue commandBuffer], encoder);
}

- (void)drawInMTKView:(MTKView*)view {
    [self updateImguiDisplayParameters:view];

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (!commandBuffer) return;

    static BOOL isInteractionEnabled = NO;
    if (!isInteractionEnabled && [IL2CPPInit isInitializationComplete]) {
        [self.view setUserInteractionEnabled:YES];
        isInteractionEnabled = YES;
    }

    MTLRenderPassDescriptor* renderPass = view.currentRenderPassDescriptor;
    if (renderPass) {
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPass];
        [encoder pushDebugGroup:@"UI Overlay"];
        [self prepareAndRenderImGui:view encoder:encoder];
        [encoder popDebugGroup];
        [encoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

@end
