//
//  JGStackedCollectionView.m
//
//  Created by Jay Gajjar on 07.01.15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "JGStackedCollectionView.h"
#import "JGCardLayout.h"
#import "JGStackedLayout.h"

@interface JGStackedCollectionView ()<UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>{
    UILongPressGestureRecognizer *longPressGesture;
    NSIndexPath *movingIndexPath;
    UIView *movingView;
    JGStackedLayout *stackedLayout;
    CGPoint initialPoint;
    // Delegate to respond back
    id <UICollectionViewDataSource> stackDataSource;
    id <UICollectionViewDelegate> stackDelegate;
    BOOL isScrolling;

}

@end

@implementation JGStackedCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initVals];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initVals];
    }
    
    return self;
}

-(void)initVals{
    stackedLayout = (JGStackedLayout *)self.collectionViewLayout;
}


#pragma mark - UICollectionView
- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    // The order here is important, as there seem to be some observing done on setDelegate:
    if (delegate == self) {
        _stackDelegate = nil;
    } else {
        _stackDelegate = delegate;
    }
    [super setDelegate:self];
}

- (id<UICollectionViewDelegate>)delegate {
    return _stackDelegate;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    // The order here is important, as there seem to be some observing done on setDelegate:
    if (dataSource == self) {
        _stackDataSource = nil;
    } else {
        _stackDataSource = dataSource;
    }
    [super setDataSource:self];
}

- (id<UICollectionViewDataSource>)dataSource {
    return _stackDataSource;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [_stackDelegate respondsToSelector:aSelector] || [_stackDataSource respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_stackDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_stackDelegate];
    } else if ([_stackDataSource respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_stackDataSource];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = nil;
    if ([_stackDataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        cell = [_stackDataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.delaysTouchesBegan = YES;
    longPressGesture.delaysTouchesEnded = YES;
    longPressGesture.allowableMovement = 50;
    //longPressGesture.delegate = self;
    [cell.contentView addGestureRecognizer:longPressGesture];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_stackDataSource collectionView:collectionView numberOfItemsInSection:section];
}


#pragma mark - Pan Gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
    static CGPoint startCenter;
    static CGPoint startLocation;
    
    CGPoint velocity = [recognizer locationInView:self];
    double dx = velocity.x - initialPoint.x;
    
    //NSLog(@"Vel X: %f | W: %f",dx ,self.frame.size.width/3);
    if(dx > 0 || dx < 0)
    {
        
        switch (recognizer.state) {
                
            case UIGestureRecognizerStateBegan: {
                initialPoint = [recognizer locationInView:self]; // _initial is instance var of type CGPoint
                
                startLocation = [recognizer locationInView:self];
                
                NSIndexPath *indexPath = [self indexPathForItemAtPoint:startLocation];
                
                if (indexPath) {
                    
                    UICollectionViewCell *movingCell = [self cellForItemAtIndexPath:indexPath];
                    
                    
                    movingView = [[UIView alloc] initWithFrame:movingCell.frame];
                    
                    startCenter = movingView.center;
                    
                    UIImageView *movingImageView = [[UIImageView alloc] initWithImage:[self screenshotImageOfItem:movingCell]];
                    
                    movingImageView.alpha = 0.0f;
                    
                    [movingView addSubview:movingImageView];
                    
                    UICollectionViewLayoutAttributes *movingCellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                    movingView.layer.transform = movingCellAttributes.transform3D;

                    
                    if (indexPath.row == [_stackDataSource collectionView:self numberOfItemsInSection:0]-1) {
                        [self addSubview:movingView];
                    }else{
                        [self insertSubview:movingView belowSubview:movingCell];
                    }
                    
                    
                    movingIndexPath = indexPath;
                    movingImageView.alpha = 1.0f;
                    
                    stackedLayout.movingIndexPath = movingIndexPath;
                    [stackedLayout invalidateLayout];
                }
                
                break;
            }
                
            case UIGestureRecognizerStateChanged: {
                
                if (movingIndexPath) {
                    
                    CGPoint currentLocation = [recognizer locationInView:self];
                    CGPoint currentCenter = startCenter;
                    
                    //currentCenter.y += (currentLocation.y - startLocation.y);
                    currentCenter.x += (currentLocation.x - startLocation.x);
                    
                    movingView.center = currentCenter;
                    movingView.alpha = 1-fabs((currentLocation.x - startLocation.x)/self.frame.size.width);
                    movingView.transform = CGAffineTransformMakeScale(1-fabs((currentLocation.x - startLocation.x)/self.frame.size.width), 1-fabs((currentLocation.x - startLocation.x)/self.frame.size.width));
                    
                    UICollectionViewLayoutAttributes *movingCellAttributes = [self layoutAttributesForItemAtIndexPath:movingIndexPath];
                    movingView.layer.transform = movingCellAttributes.transform3D;

                }
                
                break;
            }
                
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                
                CGPoint currentLocation = [recognizer locationInView:self];
                
                if(dx > 0)
                {
                    //NSLog(@"gesture went right");
                    if (currentLocation.x > self.frame.size.width/3) {
                        [self removeItemAtIndexpath:movingIndexPath];
                        [self animateMovingViewInside:NO InDirectionLeft:NO];
                    }else{
                        [self animateMovingViewInside:YES InDirectionLeft:NO];
                    }
                }
                else
                {
                    //NSLog(@"gesture went left");
                    if (currentLocation.x < self.frame.size.width/3) {
                        [self removeItemAtIndexpath:movingIndexPath];
                        [self animateMovingViewInside:NO InDirectionLeft:YES];
                    }else{
                        [self animateMovingViewInside:YES InDirectionLeft:YES];
                    }
                }
            }
                
            default:
            {
                
            }
                break;
        }
    }
}

#pragma mark - Helpers
- (UIImage *)screenshotImageOfItem:(UICollectionViewCell *)item {
    
    UIGraphicsBeginImageContextWithOptions(item.bounds.size, item.isOpaque, 0.0f);
    
    [item.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)animateMovingViewInside:(BOOL)inside InDirectionLeft:(BOOL) isLeft{
    CGFloat tx,ty;
    CGRect movingFrame;
    
    UICollectionViewLayoutAttributes *layoutAttributes = [stackedLayout layoutAttributesForItemAtIndexPath:movingIndexPath];
    if (inside) {
        tx = 1.0f;
        ty = 1.0f;
        movingFrame = layoutAttributes.frame;
    }else{
        tx = 0;
        ty = 0;
        if (isLeft) {
            movingFrame = CGRectMake(0, layoutAttributes.frame.origin.y, layoutAttributes.frame.size.width, layoutAttributes.frame.size.height);
        }else{
            movingFrame = CGRectMake(self.frame.size.width, layoutAttributes.frame.origin.y, layoutAttributes.frame.size.width, layoutAttributes.frame.size.height);
        }
    }
    
    if (movingIndexPath) {
        movingIndexPath = nil;
        
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^ (void) {
                             
                             __strong typeof(self) strongSelf = weakSelf;
                             
                             if (strongSelf) {
                                 
                                 movingView.transform = CGAffineTransformMakeScale(tx, ty);
                                 movingView.frame = movingFrame;
                             }
                         }
                         completion:^ (BOOL finished) {
                             
                             __strong typeof(self) strongSelf = weakSelf;
                             
                             if (strongSelf) {
                                 
                                 [movingView removeFromSuperview];
                                 movingView = nil;
                                 
                                 stackedLayout.movingIndexPath = nil;
                                 [stackedLayout invalidateLayout];
                             }
                         }];
    }
}

#pragma mark - CollectionView CRUD
-(void)insertItem{
    [_collDataSource addObject:[NSString stringWithFormat:@"%lu",_collDataSource.count+1]];
    [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_collDataSource.count-1 inSection:0]]];
}

-(void)removeItemAtIndexpath:(NSIndexPath *)index{
    [_collDataSource removeObjectAtIndex:index.row];
    [self deleteItemsAtIndexPaths:@[index]];
}

#pragma mark - GestureRecognizerDelegate protocol

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isEqual:longPressGesture] && isScrolling == NO) {
        return NO;
    }
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - UIScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    isScrolling = YES;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    isScrolling = NO;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    isScrolling = NO;
}
@end
