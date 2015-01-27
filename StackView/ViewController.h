//
//  ViewController.h
//  StackView
//
//  Created by Jay on 20/01/15.
//  Copyright (c) 2015 ccc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGStackedCollectionView.h"

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
- (IBAction)addButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet JGStackedCollectionView *collView;


@end

