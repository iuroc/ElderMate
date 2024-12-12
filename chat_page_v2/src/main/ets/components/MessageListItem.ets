import { Message } from '../common/Message'
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { BSColorGroup } from '../common/types'
import { BSColor } from '@iuroc/bootstrap5-color'
import {
    copyTextWithToast,
    getShareTextTitle,
    selectableItems,
    sendMailWithToast,
    systemShareTextWithToast
} from '../common/utils'

@ComponentV2
export struct MessageListItem {
    @Param @Require message: Message
    @Local showMenu: boolean = false
    @Param @Require messages: Message[]
    @Consumer() themeColor: BSColorGroup = Object()
    @Consumer() isSelectMode: boolean = false
    @Consumer() autoScrollBottom: boolean = false
    @Param @Require index: number

    aboutToAppear(): void {
    }

    build() {
        if (!this.message.hidden && (!this.isSelectMode || this.message.role)) {
            Flex({
                space: { main: LengthMetrics.vp(10) },
                justifyContent: this.makeJustifyContent()
            }) {
                if (this.isSelectMode) {
                    this.CheckBox()
                    Blank()
                }
                if (this.message.role == 'user') {
                    this.Bubble()
                    this.Avatar()
                } else {
                    this.Avatar()
                    this.Bubble()
                }
            }
            .onClick(() => {
                if (this.isSelectMode) this.toggleSelected()
            })
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

    @Builder
    Center() {
        Column() {
            this.Bubble()
        }
        .layoutWeight(1)
        .alignItems(this.makeCenterAlignItems())
    }

    makeCenterAlignItems() {
        switch (this.message.role) {
            case 'user':
                return HorizontalAlign.End
            default:
                return HorizontalAlign.Start
        }
    }

    @Builder
    CheckBox() {
        Checkbox()
            .flexShrink(0)
            .select(this.message.selected)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onClick(() => {
                this.toggleSelected()
            })
            .margin(0)
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
                if (this.isSelectMode) {
                    this.toggleSelected()
                } else if (this.message.role) {
                    this.showMenu = true
                }
            })
            .bindMenu(this.showMenu,
                this.bubbleMenuElements(),
                {
                    enableArrow: true,
                    aboutToDisappear: () => {
                        this.showMenu = false
                    },
                })
        // .gesture(LongPressGesture().onAction(() => {
        //     if (!this.isSelectMode) {
        //         this.textSelectModalText = this.message.content
        //         this.isTextSelectModalShow = true
        //     }
        // }))
    }

    toggleSelected() {
        if (this.isSelectMode && this.message.role) {
            this.message.selected = !this.message.selected
        }
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
                .flexShrink(0)
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

    bubbleMenuElements(): MenuElement[] {
        return [
            {
                value: $r('app.string.copy_text'),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle')),
                action: () => {
                    copyTextWithToast(this.message.content)
                }
            },
            {
                value: $r('app.string.select_text'),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.selector')),
                action: () => {
                    // that.isTextSelectModalShow = true
                    // that.textSelectModalText = that.messageData.content
                }
            },
            {
                value: $r('app.string.share_text'),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: async () => {
                    systemShareTextWithToast(
                        await getShareTextTitle(),
                        this.message.content
                    )
                },
            },
            {
                value: $r('app.string.multi_select_mode'),
                enabled: selectableItems(this.messages).length > 1,
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    // 禁用自动滚动底部（因为切换多选模式时列表高度会变化，将触发自动滚动底部）
                    this.autoScrollBottom = false
                    // 进入多选模式
                    this.isSelectMode = true
                    // 选中触发菜单的那条消息
                    this.message.selected = true
                }
            },
            {
                value: $r('app.string.send_to_email'),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),

                action: async () => {
                    sendMailWithToast(await getShareTextTitle(), this.message.content)
                }
            },
            {
                value: $r('app.string.delete_message'),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
                action: () => {
                    this.autoScrollBottom = false
                    this.messages.splice(this.index, 1)
                },
            },
        ]
    }
}