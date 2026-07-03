#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import <QuartzCore/CVDisplayLink.h> // for CoreVideo  - for gameloop
#import <QuartzCore/CAMetalLayer.h> // for Metal based CoreAnimation Layer - for surface

// Macros
#define WIN_WIDTH 800
#define WIN_HEIGHT 600

//C Style Function For DisplayLink!.
CVReturn displayLinkCallback (CVDisplayLinkRef, const CVTimeStamp *, const CVTimeStamp *, CVOptionFlags, CVOptionFlags *, void *);

// Global Variables Declaration
int winWidth = WIN_WIDTH;
int winHeight = WIN_HEIGHT;
BOOL bActiveWindow = NO;
BOOL bFullScreen = NO;
BOOL bWindowMinimized = NO;

char gszLogFileName[] = "_VulkanWindowLog.txt";
FILE *fptr = NULL;

// Forward Interface Declaration
@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@end

@interface View: NSView <NSWindowDelegate>
@end



// Main
int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSApp = [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    [NSApp setDelegate: [[AppDelegate alloc] init]];

    [NSApp run];

    [pool release];
    
    return 0;
}

// AppDelegate Implementation
@implementation AppDelegate {
    @private 
        NSWindow *window;
        View *view;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {

    // Code
    //Log File!.
    NSBundle *appBundle = [NSBundle mainBundle];
    NSString *appDirName = [appBundle bundlePath];
    NSString *parentDirPath = [appDirName stringByDeletingLastPathComponent];
    NSString *logFileNameWithPath = [NSString stringWithFormat:@"%@/%s", parentDirPath, gszLogFileName];
    const char* szLogFileName = [logFileNameWithPath cStringUsingEncoding:NSASCIIStringEncoding];
    
    fptr = fopen(szLogFileName, "w");
    if(fptr == NULL) {
        printf("Cannot Create Log File!...");
        [NSApp terminate:self];
    }
    else {
        fprintf(fptr, "Log File Created Successfully!!\n\n");
    }

     //Create Window!.
    NSRect winRect = NSMakeRect(0.0, 0.0, winWidth, winHeight);
    
    window = [[NSWindow alloc]initWithContentRect:winRect styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable backing: NSBackingStoreBuffered defer:NO];
    
    [window setTitle:@"macOS:: Window!."];
    [window center];
    [window setBackgroundColor: [NSColor blackColor]];
    
    //Create View
    view = [[View alloc] initWithFrame: winRect];
    [window setContentView: view];
    //Set Delegate
    [window setDelegate: view];
    [window makeKeyAndOrderFront: self];

    // Tell NS app to active this window ignoring other apps.
    [NSApp activateIgnoringOtherApps: YES];

}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // Code
}

- (void) dealloc {
    // Code
    [view release];
    [window release];
    [super dealloc];
}
@end

// View Implementation
@implementation View {
    @private
        CVDisplayLinkRef displayLink;
}

- (id) initWithFrame:(NSRect) rect {
    // Code
    self =[super initWithFrame:rect];
    
    if(self){

        // Convert Our view into CAMetalLayer'ed backing view.
        [self setWantsLayer: YES];
        
        int result = [self initialize];
        if(result != 0) {
            fprintf(fptr, "Initalization Failed!...\n");
        } else {
            fprintf(fptr, "Initalization Succeeded!!...\n");
        }

        // Create DisplayLink capable of being used with all active displays
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
        // Set the display link as our renderer output callback
        CVDisplayLinkSetOutputCallback(displayLink, &displayLinkCallback, self);
        // Activate the display link
        CVDisplayLinkStart(displayLink);
    }
    return self;
}

- (void) windowDidBecomeKey:(NSNotification *)notification {
    // Code
    bActiveWindow = YES;
}

- (void) windowDidResignKey:(NSNotification *)notification {
    // Code
    bActiveWindow = NO;
}

- (NSSize) windowWillResize:(NSWindow *)sender toSize:(NSSize) frameSize {
    // Code
    if(bWindowMinimized == NO) {
        CVDisplayLinkStop(displayLink);
        [self resize: frameSize.width : frameSize.height];
    }
    return frameSize;
}

- (void) windowDidResize:(NSNotification *)notification {
    // start display link again after resizing is done.
    if(bWindowMinimized == NO) {   
        CVDisplayLinkStart(displayLink);
    }
}

- (void) windowWillMiniaturize:(NSNotification *)notification {
    // Code
    bWindowMinimized = YES;
    CVDisplayLinkStop(displayLink);
}

- (void) windowDidMiniaturize:(NSNotification *)notification {
}

- (void) windowDidDeminiaturize:(NSNotification *)notification {
    // Code
    bWindowMinimized = NO;
    CVDisplayLinkStart(displayLink);
}

- (void) windowWillClose:(NSNotification *)notification {
    // Code
    [self uninitialize];
    [NSApp terminate: self];
}

- (CVReturn) getFrameForTime:(const CVTimeStamp *) outputTime {
    // Code
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // render the scene
    [self drawView];

    [pool release];
    return kCVReturnSuccess;
}

- (void) drawRect:(NSRect) dirtyRect {
    // Code
    [self drawView];
}

- (void) drawView {
    // Code
    [self display];
    [self update];
}

// To have setWantsLayer function successfull we need to override following two functions
+ (Class) layerClass {
    // Code
    return [CAMetalLayer class];
}

// to have the result of setWantsLayer as YES, we need to override this function and return YES.
- (BOOL) wantsUpdateLayer {
    return YES;
}

// to have the result of setWantsLayer, we need to override this function and return a custom layer.
- (CALayer *) makeBackingLayer {
    // Code
    CALayer *layer = [[[self class] layerClass] layer];
    CGSize viewSize = [self convertSizeToBacking:CGSizeMake(1.0, 1.0)];
    [layer setContentsScale: MIN(viewSize.width, viewSize.height)];
    return layer;
}

// To Make View As First Responder.
- (BOOL) acceptsFirstResponder {
    // Code
    [[self window] makeFirstResponder: self];
    return(YES);
}

- (void) keyDown:(NSEvent *) event {
    // Code
    //This to Take first key pressed in the multiple keyDowns
    int keyCode = (int)[[event characters] characterAtIndex:0];
    
    switch (keyCode) {
        case 27: //Esc
            if(bFullScreen == YES) {
                [[self window] toggleFullScreen:nil];
                bFullScreen = NO;
            }
            // Terminate App.
            [[self window] performClose:self];

            break;
            
        case 'F':
        case 'f':
            [[self window] toggleFullScreen:self];
            bFullScreen = !bFullScreen;
            break;
            
        default:
            break;
    }
    
}

- (void) dealloc {
    // Code
    if(displayLink) {
        CVDisplayLinkStop(displayLink);
        CVDisplayLinkRelease(displayLink);
        displayLink = NULL;
    }
    [super dealloc];
}

- (int) initialize {
    // Code
    return 0;
}

- (void) resize: (int) width : (int) height {
    // Code
}

- (void) display {
    // Code
}

- (void) update {
    // Code
}

- (void) uninitialize {
    // Code

    if(bFullScreen == YES) {
        [[self window] toggleFullScreen:nil];
        bFullScreen = NO;
    }

    if(fptr) {
        fprintf(fptr, "\nLog File Closed Successfully!!");
        fclose(fptr);
        fptr = NULL;
    }
}
@end

CVReturn displayLinkCallback (CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *renderer) {
    // Code
    CVReturn result = [(View*)renderer getFrameForTime: outputTime];
    return result;
}
