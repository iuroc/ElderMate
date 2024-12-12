import { Message } from '../common/Message'
import { LengthMetrics } from '@kit.ArkUI'
import { BSColorGroup } from '../common/types'
import { BSColor } from '@iuroc/bootstrap5-color'

@ComponentV2
export struct MessageListItem {
    @Param @Require message: Message
    @Param @Require isSelectMode: boolean
    @Param @Require themeColor: BSColorGroup = Object()

    build() {
        Row({ space: 10 }) {
            if (this.isSelectMode) {
                this.CheckBox()
            }
            if (this.message.role == 'user') {
                this.Center()
                this.Avatar()
            } else {
                this.Avatar()
                this.Center()
            }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
    }

    @Builder
    Center() {
        Column() {
            this.Bubble()
        }
        .layoutWeight(1)
        .alignItems(this.message.role == 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
    }

    @Builder
    CheckBox() {
        Checkbox()
            .flexShrink(0)
            .select(this.message.selected)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onClick(() => {
                // this.toggleSelected()
            })
            .margin({
                right: 0
            })
    }

    /** 消息列表中的消息气泡 */
    @Builder
    Bubble() {
        Text(this.message.content)
            .textAlign(TextAlign.JUSTIFY)
            .wordBreak(WordBreak.BREAK_ALL)
            .padding(10)
            .borderRadius(10)
            .fontSize(15)
            .fontColor(this.makeBubbleFontColor())
            .backgroundColor(this.makeBubbleBGColor())
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
            .border(this.makeBubbleBorder())
            .margin(this.makeBubbleMargin())
            .onClick(() => {
                // if (!this.isSelectMode) {
                //     if (this.message.role) {
                //         this.showMenu = true
                //     }
                // } else {
                //     this.toggleSelected()
                // }
            }) // .bindMenu(this.showMenu,
        //     bubbleMenuElements(this),
        //     {
        //         enableArrow: true,
        //         aboutToDisappear: () => {
        //             this.showMenu = false
        //         },
        //     })
        // .gesture(LongPressGesture().onAction(() => {
        //     if (!this.isSelectMode) {
        //         this.textSelectModalText = this.message.content
        //         this.isTextSelectModalShow = true
        //     }
        // }))
    }

    /** 聊天内容气泡的外边距 */
    makeBubbleMargin(): Padding {
        switch (this.message.role) {
            case 'user':
                return { left: this.isSelectMode ? 0 : 10 }
            default:
                return { right: this.isSelectMode ? 0 : 10 }
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(): ResourceColor {
        switch (this.message.role) {
            case 'user':
                return this.themeColor.background
            default:
                return BSColor.tertiary_bg
        }
    }

    /** 聊天内容气泡的边框 */
    makeBubbleBorder(): BorderOptions {
        switch (this.message.role) {
            case 'user':
                return {}
            default:
                return {
                    width: 1,
                    color: BSColor.border_color
                }
        }
    }

    /** 聊天内容气泡的字体颜色 */
    makeBubbleFontColor(): ResourceColor {
        switch (this.message.role) {
            case 'user':
                return this.themeColor.font
            default:
                return BSColor.dark
        }
    }

    /** 消息列表中的头像 */
    @Builder
    Avatar() {
        if (!this.isSelectMode) {
            SymbolGlyph(this.makeAvatarSymbolResource())
                .fontSize(30)
                .avatarStyles()
                .fontColor([this.makeAvatarSymbolFontColor()])
                .backgroundColor(Color.White)
        }
    }

    @Styles
    avatarStyles() {
        .padding(3)
        .borderRadius(10)
        .flexShrink(0)
        .margin({ top: 2 })
        .shadow({ radius: 10, color: $r('sys.color.ohos_id_color_list_separator') })
    }

    makeAvatarSymbolResource(): Resource {
        if (!this.message.role) {
            return $r('sys.symbol.flag')
        }
        switch (this.message.role) {
            case 'user':
                return $r('sys.symbol.person_crop_circle_fill_1')
            case 'system':
                return $r('sys.symbol.gearshape')
            case 'assistant':
                return $r('sys.symbol.lightbulb')
            default:
                throw new Error('role not allow')
        }
    }

    makeAvatarSymbolFontColor(): ResourceColor {
        if (!this.message.role) {
            return BSColor.warning
        }
        switch (this.message.role) {
            case 'user':
                return this.themeColor.main
            case 'system':
                return Color.Black
            case 'assistant':
                return this.themeColor.font
            default:
                throw new Error('role not allow')
        }
    }

    makeJustifyContent() {
        switch (this.message.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }
}