/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * 和OHASBasicHTMLParser完全一样，就改了表情大小， 原来是17
 *
 *
 ***********************************************************************************/


#import "OHASMarkupParserBase.h"

/*!
 * Supported tags:
 *
 *  " */
enum {
    FastTextAttachmentCharacter = 0xfffc // The magical Unicode character for attachments in both Cocoa (NSAttachmentCharacter) and CoreText ('run delegate' there).
};
@interface OHASBasicHTMLParser_SmallEmoji : OHASMarkupParserBase

@end
