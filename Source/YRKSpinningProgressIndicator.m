/*
 * YRKSpinningProgressIndicator.h
 * Copyright (c) 2009, Kelan Champagne (http://yeahrightkeller.com)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY Kelan Champagne ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL Kelan Champagne BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "YRKSpinningProgressIndicator.h"


@interface YRKSpinningProgressIndicator (YRKSpinningProgressIndicatorPrivate)

- (void) setupAnimTimer;
- (void) disposeAnimTimer;

@end


@implementation YRKSpinningProgressIndicator

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _position = 0;
        _numFins = 12;
        _isAnimating = NO;
        _isFadingOut = NO;
        _nextFrameUpdate = [[NSDate date] retain];
    }
    return self;
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];

    if ([self window] == nil) {
        // No window?  View hierarchy may be going away.  Dispose timer to clear circular retain of timer to self to timer.
        [self disposeAnimTimer];
    } else if (_isAnimating) {
        [self setupAnimTimer];
    }
}

- (void)drawRect:(NSRect)rect
{
    int i;
    float alpha = 1.0;

    // Determine size based on current bounds
    NSSize size = [self bounds].size;
    float maxSize;
    if(size.width >= size.height)
        maxSize = size.height;
    else
        maxSize = size.width;

    // fill the background, if set
    if(_drawBackground) {
        [_backColor set];
        [NSBezierPath fillRect:[self bounds]];
    }

    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    [NSGraphicsContext saveGraphicsState];

    // Move the CTM so 0,0 is at the center of our bounds
    CGContextTranslateCTM(currentContext,[self bounds].size.width/2,[self bounds].size.height/2);

    // do initial rotation to start place
    CGContextRotateCTM(currentContext, 3.14159*2/_numFins * _position);

    NSBezierPath *path = [[NSBezierPath alloc] init];
    float lineWidth = 0.0859375 * maxSize; // should be 2.75 for 32x32
    float lineStart = 0.234375 * maxSize; // should be 7.5 for 32x32
    float lineEnd = 0.421875 * maxSize;  // should be 13.5 for 32x32
    [path setLineWidth:lineWidth];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path moveToPoint:NSMakePoint(0,lineStart)];
    [path lineToPoint:NSMakePoint(0,lineEnd)];

    for(i=0; i<_numFins; i++) {
        if(_isAnimating) {
            [[_foreColor colorWithAlphaComponent:alpha] set];
        } else {
            [[_foreColor colorWithAlphaComponent:0.2] set];
        }

        [path stroke];

        // we draw all the fins by rotating the CTM, then just redraw the same segment again
        CGContextRotateCTM(currentContext, 6.282185/_numFins);
        alpha -= 1.0/_numFins;
    }
    [path release];

    [NSGraphicsContext restoreGraphicsState];
}

# pragma mark -
# pragma mark Subclass

- (void)animate:(id)sender
{

    if(_position > 0) {
        _position--;
    } else {
        _position = _numFins;
    }

    [self setNeedsDisplay:YES];
}

- (void) setupAnimTimer
{
    // Just to be safe kill any existing timer.
    [self disposeAnimTimer];

    if ([self window]) {
        // Why animate if not visible?  viewDidMoveToWindow will re-call this method when needed.
        _animationTimer = [[NSTimer timerWithTimeInterval:(NSTimeInterval)0.05
                                                   target:self
                                                 selector:@selector(animate:)
                                                 userInfo:nil
                                                  repeats:YES] retain];

        // FIXME: NSRunLoopCommonModes is only available on 10.5+, and I'd
        // like BBug to run on 10.4, if possible. Is there a 10.4 analog
        // for NSRunLoopCommonModes?
        //[[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
        // This is from an older version of the code that _did_ compile
        // on 10.4.
        [_animationTimer setFireDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];
    }
}

- (void) disposeAnimTimer
{
    [_animationTimer invalidate];
    [_animationTimer release];
    _animationTimer = nil;
}

- (void)startAnimation:(id)sender
{
    _isAnimating = YES;

    [self setupAnimTimer];
}

- (void)stopAnimation:(id)sender
{
    _isAnimating = NO;

    [self disposeAnimTimer];

    [self setNeedsDisplay:YES];
}

# pragma mark Not Implemented

- (void)setStyle:(NSProgressIndicatorStyle)style
{
    if (NSProgressIndicatorSpinningStyle != style) {
        NSAssert(NO, @"Non-spinning styles not available.");
    }
}


# pragma mark -
# pragma mark Accessors

- (NSColor *)foregroundColor
{
    return [[_foreColor retain] autorelease];
}

- (void)setForegroundColor:(NSColor *)value
{
    if (_foreColor != value) {
        [_foreColor release];
        _foreColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (NSColor *)backgroundColor
{
    return [[_backColor retain] autorelease];
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (_backColor != value) {
        [_backColor release];
        _backColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)drawBackground
{
    return _drawBackground;
}

- (void)setDrawBackground:(BOOL)value
{
    if (_drawBackground != value) {
        _drawBackground = value;
    }
    [self setNeedsDisplay:YES];
}

@end
