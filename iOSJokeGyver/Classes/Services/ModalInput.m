/* Copyright (c) 1996-2014 Clickteam
 *
 * This source code is part of the iOS exporter for Clickteam Multimedia Fusion 2
 * and Clickteam Fusion 2.5.
 *
 * Permission is hereby granted to any person obtaining a legal copy
 * of Clickteam Multimedia Fusion 2 or Clickteam Fusion 2.5 to use or modify this source
 * code for debugging, optimizing, or customizing applications created with
 * Clickteam Multimedia Fusion 2 and/or Clickteam Fusion 2.5.
 * Any other use of this source code is prohibited.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
#import "ModalInput.h"

@implementation ModalInput

//@synthesize textField;
//@synthesize passwordField;
//@synthesize text;
//@synthesize password;

-(id)initStringWithTitle:(NSString *)title message:(NSString *)message fromViewController:(MainViewController *)controller cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    self = [super init];
    _mainController = controller;
    
    if ((_alert = [UIAlertController alertControllerWithTitle:title
                                                      message:message
                                               preferredStyle:UIAlertControllerStyleAlert]))
    {
        // Add text field
        [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Text";
            textField.textAlignment = NSTextAlignmentNatural;
            textField.secureTextEntry = NO;
        }];
        
        //Add Buttons
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okayButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle your OK button action here
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:_alert.textFields[0].text];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:cancelButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle cancel button
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:@""];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        //Add your buttons to alert controller
        [_alert addAction:okButton];
        [_alert addAction:noButton];
        
    }
    return self;
}

-(id)initNumberWithTitle:(NSString *)title message:(NSString *)message fromViewController:(MainViewController *)controller cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    self = [super init];
    _mainController = controller;
    
    if ((_alert = [UIAlertController alertControllerWithTitle:title
                                                      message:message
                                               preferredStyle:UIAlertControllerStyleAlert]))
    {
        // Add text field
        [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Number";
            textField.textAlignment = NSTextAlignmentRight;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.secureTextEntry = NO;
        }];
        
        //Add Buttons
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okayButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle your OK button action here
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:_alert.textFields[0].text];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:cancelButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle cancel button
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:@""];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        //Add your buttons to alert controller
        [_alert addAction:okButton];
        [_alert addAction:noButton];
        
    }
    return self;
    
}

-(id)initNamePasswordWithTitle:(NSString *)title message:(NSString *)message fromViewController:(MainViewController *)controller cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    self = [super init];
    _mainController = controller;
    
    if ((_alert = [UIAlertController alertControllerWithTitle:title
                                                      message:message
                                               preferredStyle:UIAlertControllerStyleAlert]))
    {
        // Add text fields
        [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Name";
            textField.textAlignment = NSTextAlignmentNatural;
            textField.secureTextEntry = NO;
        }];
        
        [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Password";
            textField.textAlignment = NSTextAlignmentNatural;
            textField.secureTextEntry = YES;
        }];
        
        //Add Buttons
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okayButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle your OK button action here
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:_alert.textFields[0].text];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:_alert.textFields[1].text];
            
            [self endedWithAction:action];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:cancelButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle cancel button
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:@""];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        //Add your buttons to alert controller
        [_alert addAction:okButton];
        [_alert addAction:noButton];
        
    }
    return self;
}

-(id)initMultiLineStringWithTitle:(NSString *)title message:(NSString *)message fromViewController:(MainViewController *)controller cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    self = [super init];
    _mainController = controller;
    
    if ((_alert = [UIAlertController alertControllerWithTitle:title
                                                      message:message
                                               preferredStyle:UIAlertControllerStyleAlert]))
    {
        // Add text field
        UIViewController *controller = [[UIViewController alloc]init];
        
        // Some size
        CGRect rect = CGRectMake(0, 0, 272, 250);
        [controller setPreferredContentSize:rect.size];
        
        // The text view to be used
        UITextView *textView = [[UITextView alloc]initWithFrame:rect];
        textView.scrollEnabled = YES;
        textView.tag = 1;
        
        [controller.view addSubview:textView];
        
        [controller.view bringSubviewToFront:textView];
        [controller.view setUserInteractionEnabled:YES];
        
        [_alert setValue:controller forKey:@"contentViewController"];
        
        //Add Buttons
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okayButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle your OK button action here
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:textView.text];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:cancelButtonTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
            //Handle cancel button
            if(self.text != nil)
                [self.text release];
            self.text = [[NSString alloc] initWithString:@""];
            
            if(self.password != nil)
                [self.password release];
            self.password = [[NSString alloc] initWithString:@""];
            
            [self endedWithAction:action];
        }];
        
        //Add your buttons to alert controller
        [_alert addAction:okButton];
        [_alert addAction:noButton];
        
    }
    return self;
}

- (void)setTextField:(NSString *)string at:(int)index
{
    if(_alert != nil)
    {
        if([_alert.textFields count] > 0)
        {
            UITextField* textField = _alert.textFields[index];
            if(textField != nil)
                [textField setText:string];
        }
        else
        {
            UIView* view = [(UIViewController*)([_alert valueForKey:@"contentViewController"]) view];
            UITextView* textView = [view viewWithTag:1];
            if(textView != nil)
                [textView setText:string];

        }
    }
}

- (void)show
{
    if(_mainController != nil)
        [_mainController presentViewController:_alert animated:YES completion:nil];
}

- (void)dealloc
{
    if(self.text != nil)
        [self.text release];
    if(self.password != nil)
        [self.password release];
    [super dealloc];
}

-(void)endedWithAction:(UIAlertAction*)action
{
    if([_delegate respondsToSelector:@selector(endedWithAction:andAlertController:)])
        [_delegate endedWithAction:action andAlertController:_alert];
    [_alert dismissViewControllerAnimated:YES completion:nil];
}

@end
