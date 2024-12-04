import { BSColor, BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { ChatCompletionMessageParam_role } from '@iuroc/openai/src/main/ets/types'
import { LengthMetrics } from '@kit.ArkUI'

@Component
export struct MessageListItem {
    @Consume messageDataList: MessageData[]
    @Consume themeColor: BSColorNameMap
    @Require messageData?: MessageData

    build() {
        if (!this.messageData?.hidden) {
            Row({ space: 10 }) {
                if (this.messageData?.role == 'user') {
                    this.Bubble()
                    this.Avatar()
                } else {
                    this.Avatar()
                    this.Bubble()
                }
            }
            .alignItems(VerticalAlign.Top)
        }
    }

    /** 消息列表中的消息气泡 */
    @Builder
    Bubble() {
        Text(this.messageData?.content + '\n' + this.messageData?.selected)
            .padding(10)
            .borderRadius(10)
            .layoutWeight(1)
            .margin(this.makeBubbleMargin())
            .fontColor(this.makeBubbleFontColor())
            .backgroundColor(this.makeBubbleBGColor())// .bindMenu(
                //     this!.messageData.role != 'info' && !this.isSelectMode
                //         ? this.MessageBubbleMenu() : undefined)
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
            .border(this.makeBubbleBorder())
            .onClick(() => {
                // this.toggleSelected()
            })
            .gesture(LongPressGesture().onAction(() => {
                this.messageDataList.forEach((item, index) => {
                    if (item.id == this.messageData?.id) {
                        this.messageDataList.splice(index, 1)
                    }
                })
            }))
            .bindMenu([
                {
                    value: '复制',
                    action: () => {
                    }
                }
            ])
    }

    toggleSelected() {
        this.messageData!.selected = !this.messageData?.selected
    }

    /** 聊天内容气泡的外边距 */
    makeBubbleMargin(): Padding {
        switch (this.messageData?.role) {
            case 'user':
                return { left: 10 }
            default:
                return { right: 10 }
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(): ResourceColor {
        switch (this.messageData?.role) {
            case 'user':
                return getColorGroup(this.themeColor).background
            default:
                return BSColor.tertiary_bg
        }
    }

    /** 聊天内容气泡的边框 */
    makeBubbleBorder(): BorderOptions {
        switch (this.messageData?.role) {
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
        switch (this.messageData?.role) {
            case 'user':
                return getColorGroup(this.themeColor).font
            default:
                return BSColor.dark
        }
    }

    /** 消息列表中的头像 */
    @Builder
    Avatar() {
        SymbolGlyph(this.makeAvatarSymbolResource())
            .fontSize(30)
            .avatarStyles()
            .fontColor([this.makeAvatarSymbolFontColor()])
            .backgroundColor(Color.White)
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
        if (!this.messageData?.role) {
            return $r('sys.symbol.flag')
        }
        switch (this.messageData?.role) {
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
        if (!this.messageData?.role) {
            return BSColor.warning
        }
        switch (this.messageData?.role) {
            case 'user':
                return getColorGroup(this.themeColor).main
            case 'system':
                return Color.Black
            case 'assistant':
                return Color.Gray
            default:
                throw new Error('role not allow')
        }
    }

    makeJustifyContent() {
        switch (this.messageData?.role) {
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
    @Trace id: number = NextID++
    @Trace createTime: Date

    constructor(data: MessageDataInit) {
        this.inRequest = data.inRequest ?? true
        this.role = data.role ?? null
        this.content = data.content
        this.hidden = data.hidden ?? false
        this.selected = data.selected ?? false
        this.createTime = data.createTime ?? new Date()
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