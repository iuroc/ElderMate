import { BSColor, BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { ChatCompletionMessageParam_role } from '@iuroc/openai/src/main/ets/types'
import { LengthMetrics } from '@kit.ArkUI'
import { bubbleMenuElements } from '../config/bubbleMenuElements'

@Component
export struct MessageListItem {
    @Consume messageDataList: MessageData[]
    @Consume themeColor: BSColorNameMap
    @Require messageData: MessageData = Object()
    @Consume isSelectMode: boolean
    @State showMenu: boolean = false
    @Consume isTextSelectModalShow: boolean
    @Consume textSelectModalText: string

    build() {
        if (!this.messageData.hidden && (!this.isSelectMode || this.messageData.role)) {
            Flex({
                space: { main: LengthMetrics.vp(10) },
                justifyContent: this.makeJustifyContent()
            }) {
                if (this.isSelectMode) {
                    this.Checkbox()
                    Blank()
                }
                if (this.messageData.role == 'user') {
                    this.Bubble()
                    this.Avatar()
                } else {
                    this.Avatar()
                    this.Bubble()
                }
            }
            .onClick(() => {
                this.toggleSelected()
            })
        }
    }

    /** 消息多选项 */
    @Builder
    Checkbox() {
        Checkbox()
            .flexShrink(0)
            .select(this.messageData.selected)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onClick(() => {
                this.toggleSelected()
            })
            .margin({
                right: 0
            })
    }

    /**
     * @deprecated
     */
    @Builder
    CenterPanel() {
        Column({ space: 5 }) {
            this.Bubble()
            this.TimeView()
        }
        .alignItems(this.messageData.role == 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
    }

    @Builder
    TimeView() {
        Text(this.messageData.createTime.toLocaleString()).fontSize(12).fontColor(BSColor.secondary)
            .margin({ left: 10, right: 10 })
    }

    /** 消息列表中的消息气泡 */
    @Builder
    Bubble() {
        Text(this.messageData.content)
            .textAlign(TextAlign.JUSTIFY)
            .wordBreak(WordBreak.BREAK_ALL)
            .padding(10)
            .maxLines(15)
            .borderRadius(10)
            .margin(this.makeBubbleMargin())
            .fontSize(15)
            .fontColor(this.makeBubbleFontColor())
            .backgroundColor(this.makeBubbleBGColor())
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
            .border(this.makeBubbleBorder())
            .onClick(() => {
                if (!this.isSelectMode) {
                    if (this.messageData.role) {
                        this.showMenu = true
                    }
                } else {
                    this.toggleSelected()
                }
            })
            .bindMenu(this.showMenu,
                bubbleMenuElements(this),
                {
                    enableArrow: true,
                    aboutToDisappear: () => {
                        this.showMenu = false
                    },
                })
    }

    toggleSelected() {
        if (this.isSelectMode && this.messageData.role) {
            this.messageData.selected = !this.messageData.selected
        }
    }

    /** 聊天内容气泡的外边距 */
    makeBubbleMargin(): Padding {
        switch (this.messageData.role) {
            case 'user':
                return { left: this.isSelectMode ? 0 : 10 }
            default:
                return { right: this.isSelectMode ? 0 : 10 }
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(): ResourceColor {
        switch (this.messageData.role) {
            case 'user':
                return getColorGroup(this.themeColor).background
            default:
                return BSColor.tertiary_bg
        }
    }

    /** 聊天内容气泡的边框 */
    makeBubbleBorder(): BorderOptions {
        switch (this.messageData.role) {
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
        switch (this.messageData.role) {
            case 'user':
                return getColorGroup(this.themeColor).font
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
        if (!this.messageData.role) {
            return $r('sys.symbol.flag')
        }
        switch (this.messageData.role) {
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
        if (!this.messageData.role) {
            return BSColor.warning
        }
        switch (this.messageData.role) {
            case 'user':
                return getColorGroup(this.themeColor).main
            case 'system':
                return Color.Black
            case 'assistant':
                return getColorGroup(this.themeColor).font
            default:
                throw new Error('role not allow')
        }
    }

    makeJustifyContent() {
        switch (this.messageData.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }
}

let NextID = 0

@ObservedV2
export class MessageData implements IMessageData {
    @Trace inRequest: boolean
    @Trace role: ChatCompletionMessageParam_role | null
    @Trace content: string
    @Trace hidden: boolean
    @Trace selected: boolean
    @Trace id: number
    @Trace createTime: Date

    constructor(data: MessageDataInit) {
        this.inRequest = data.inRequest ?? true
        this.role = data.role ?? null
        this.content = data.content
        this.hidden = data.hidden ?? false
        this.selected = data.selected ?? false
        this.createTime = data.createTime ?? new Date()
        this.id = NextID++
    }
}

export interface MessageDataInit {
    /** 消息是否需要加入请求体，默认 `true` */
    inRequest?: boolean
    /** 消息角色，默认 `null` */
    role?: ChatCompletionMessageParam_role | null
    /** 消息气泡内容 */
    content: string
    /** 是否隐藏组件，默认 `false` */
    hidden?: boolean
    /** 是否选中组件，默认 `false` */
    selected?: boolean
    /** 消息创建时间，默认 `new Date()` */
    createTime?: Date
}

export type IMessageData = Required<MessageDataInit>
