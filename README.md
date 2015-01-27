JGCustomSelection
<<<<<<< HEAD
========================

A selection controller made with combinitation of UITableView and UICollectionview

# Installation
    Copy JGCustomSelection from the storyboard and initialize the viewcontroller whenever needed
## Manual
Add the files in the classes folder to your project.

# Usage

```  objc
JGCustomSelection *customSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"JGCustomSelection"];
customSelection.tableViewDataArray = [[self generateDataSource] mutableCopy];
customSelection.delegate = self;
[self presentViewController:customSelection animated:YES completion:^{

}];



#pragma mark - JGCustomSelectionDelegate

-(void)JGCustomSelectionSelectedValues:(NSArray *)selectedValues{
    self.resultLbl.text = [NSString stringWithFormat:@"%lu developers selected",(unsigned long)selectedValues.count];
}

```

# Demo
JGCustomSelection includes a sample project and revelent classes.

# Compatibility
- This project uses ARC.
- This project was tested with iOS 7 & 8.

# License
JGCustomSelection is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
=======
=================
>>>>>>> 8c0a9cb73879fbc1bd726f2074a95355ca0c292a
