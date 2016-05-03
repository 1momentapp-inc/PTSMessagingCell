/*
 PTSMessagingCell.m
 
 Copyright (C) 2012 pontius software GmbH
 
 This program is free software: you can redistribute and/or modify
 it under the terms of the Createive Commons (CC BY-SA 3.0) license
*/

#import <UIKit/UIKit.h>

#import "PTSMessagingCell.h"

@implementation PTSMessagingCell

static CGFloat textMarginHorizontal = 45.0f;
static CGFloat textMarginVertical = 7.0f;
static CGFloat messageTextSize = 13.0;

@synthesize sent, messageLabel, messageView, timeLabel, avatarImageView, balloonView;

#pragma mark -
#pragma mark Static methods

+(CGFloat)textMarginHorizontal {
    return textMarginHorizontal;
}

+(CGFloat)textMarginVertical {
    return textMarginVertical;
}

+(CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 220.0f;
    } else {
        return 400.0f;
    }
}

+(CGSize)messageSize:(NSString*)message {
    return [message boundingRectWithSize: CGSizeMake([PTSMessagingCell maxTextWidth], CGFLOAT_MAX)
                                 options: 0
                              attributes: @{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:12]}
                                 context: nil].size;
}

+(UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected {
    if (sent == YES && selected == YES) {
        return [[UIImage imageNamed:@"balloon_selected_right"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == YES && selected == NO) {
        return [[UIImage imageNamed:@"balloon_read_right"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == NO && selected == YES) {
        return [[UIImage imageNamed:@"balloon_selected_left"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else {
        return [[UIImage imageNamed:@"balloon_read_left"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    }
}

#pragma mark -
#pragma mark Object-Lifecycle/Memory management

-(id)initMessagingCellWithReuseIdentifier:(NSString*)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        /*Selection-Style of the TableViewCell will be 'None' as it implements its own selection-style.*/
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        /*Now the basic view-lements are initialized...*/
        messageView = [[UIView alloc] initWithFrame:CGRectZero];
        messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        avatarImageView = [[PFImageView alloc] initWithImage:nil];
       
        /*Message-Label*/
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:messageTextSize];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        /*Time-Label*/
        self.timeLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:8.0];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        /*...and adds them to the view.*/
        [self.messageView addSubview: self.balloonView];
        [self.messageView addSubview: self.messageLabel];
        
        [self.contentView addSubview: self.timeLabel];
        [self.contentView addSubview: self.messageView];
        [self.contentView addSubview: self.avatarImageView];
        
        /*...and a gesture-recognizer, for LongPressure is added to the view.*/
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:1.0f];
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}


#pragma mark -
#pragma mark Layouting

- (void)layoutSubviews {
    /*This method layouts the TableViewCell. It calculates the frame for the different subviews, to set the layout according to size and orientation.*/
    
    /*Calculates the size of the message. */
    CGSize textSize = [PTSMessagingCell messageSize:self.messageLabel.text];
    
    /*Calculates the size of the timestamp.*/
    CGSize dateSize = [self.timeLabel.text boundingRectWithSize: CGSizeMake([PTSMessagingCell maxTextWidth], CGFLOAT_MAX)
                                                        options: NSStringDrawingTruncatesLastVisibleLine
                                                     attributes: @{NSFontAttributeName:self.timeLabel.font}
                                                        context: nil].size;
//    [self.timeLabel.text sizeWithFont: self.timeLabel.font forWidth:[PTSMessagingCell maxTextWidth] lineBreakMode:NSLineBreakByClipping];
    
    if (self.sent == YES) {
        self.balloonView.frame = CGRectMake(self.frame.size.width - (textSize.width + 2*textMarginHorizontal)+20, self.timeLabel.frame.size.height, textSize.width+20 , textSize.height + 2*textMarginVertical);
        
        self.messageLabel.frame = CGRectMake(self.frame.size.width - (textSize.width + textMarginHorizontal)-20,  self.balloonView.frame.origin.y + textMarginVertical, textSize.width, textSize.height);

        self.avatarImageView.frame = CGRectMake(self.frame.size.width-40, textSize.height + 2*textMarginVertical-18, 30, 30);
    self.timeLabel.frame = CGRectMake(self.frame.size.width - dateSize.width - textMarginHorizontal-4, self.avatarImageView.frame.origin.y+30, dateSize.width, dateSize.height);
    }
    else {
        self.timeLabel.frame = CGRectMake(textMarginHorizontal-5, self.frame.size.height-5, dateSize.width, dateSize.height);
        
        self.balloonView.frame = CGRectMake(40.0f, self.timeLabel.frame.size.height, textSize.width + 20, textSize.height + 2*textMarginVertical);
        
        self.messageLabel.frame = CGRectMake(textMarginHorizontal+10, self.balloonView.frame.origin.y + textMarginVertical, textSize.width, textSize.height);
        
        self.avatarImageView.frame = CGRectMake(5, textSize.height + 2*textMarginVertical-18, 30, 30);
        
        
    }
    self.avatarImageView.layer.cornerRadius = 15;
    self.avatarImageView.clipsToBounds = YES;
    
    self.balloonView.image = [PTSMessagingCell balloonImage:self.sent isSelected:self.selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	/*Selecting a UIMessagingCell will cause its subviews to be re-layouted. This process will not be animated! So handing animated = YES to this method will do nothing.*/
    [super setSelected:selected animated:NO];
    
    [self setNeedsLayout];
    
    /*Furthermore, the cell becomes first responder when selected.*/
    if (selected == YES) {
        [self becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
}

#pragma mark -
#pragma mark UIGestureRecognizer-Handling

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    /*When a LongPress is recognized, the copy-menu will be displayed.*/
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([self becomeFirstResponder] == NO) {
        return;
    }
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.balloonView.frame inView:self];
    
    [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder {
    /*This cell can become first-responder*/
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    /*Allows the copy-Action on this cell.*/
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

-(void)copy:(id)sender {
    /**Copys the messageString to the clipboard.*/
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.messageLabel.text];
}
@end


