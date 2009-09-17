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

#import <Cocoa/Cocoa.h>


@interface YRKSpinningProgressIndicator : NSView {
    int _position;
    NSDate *_nextFrameUpdate;
    int _numFins;

    BOOL _isAnimating;
    NSTimer *_animationTimer;

    NSColor *_foreColor;
    NSColor *_backColor;
    BOOL _drawBackground;

    NSTimer *_fadeOutAnimationTimer;
    BOOL _isFadingOut;
}
- (void)animate:(id)sender;
- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;

- (NSColor *)foregroundColor;
- (void)setForegroundColor:(NSColor *)value;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)value;

- (BOOL)drawBackground;
- (void)setDrawBackground:(BOOL)value;

@end
