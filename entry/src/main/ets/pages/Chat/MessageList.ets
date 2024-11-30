import { changeAllSelectStatus, deleteByUUID, MessageData, systemShareText } from "./util"
import { LengthMetrics, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { BusinessError, pasteboard } from "@kit.BasicServicesKit"
import { common } from "@kit.AbilityKit"
import { util } from "@kit.ArkTS"

/**
 * 消息列表容器
 */
@Component
export struct MessageList {
    scroller = new Scroller()
    textAreaController = new TextAreaController()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Link dataList: MessageData[]
    @Link textSelectModalText: string
    /** 是否处于多选模式 */
    @Link isSelectMode: boolean
    @Link isModalShow: boolean
    @Require @Prop textShareTitle: string = ''
    /** Scroll 是否已经执行过 onSizeChange 回调 */
    hasInitSizeChange: boolean = false

    build() {
        Scroll(this.scroller) {
            Column({ space: 20 }) {
                ForEach(this.dataList, (item: MessageData) => {
                    this.MessageItem(item)
                })
            }
            .margin(20)
        }
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.textAreaController.stopEditing()
            }
        })
        .align(Alignment.Top)
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .flexGrow(1)
        .onSizeChange(event => {
            if (this.hasInitSizeChange) {
                return
            }
            if (event.height && event.height > 0) {
                this.hasInitSizeChange = true
                this.scroller.scrollEdge(Edge.Bottom)
            }
        })
    }

    /** 消息列表项，包含头像和消息气泡 */
    @Builder
    MessageItem(item: MessageData) {
        if (!item.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(item),
        }) {
            if (this.isSelectMode && item.role != 'info') {
                this.MessageCheckbox(item)
                Blank()
            }
            if (item.role == 'user') {
                this.MessageBubble(item)
                this.MessageAvatar(item)
            } else {
                this.MessageAvatar(item)
                this.MessageBubble(item)
            }
        }.onClick(() => {
            if (this.isSelectMode) {
                this.toggleSelected(item.uuid)
            }
        })
    }

    /** 消息多选项 */
    @Builder
    MessageCheckbox(item: MessageData) {
        Checkbox()
            .flexShrink(0)
            .select(item.selected)
            .onChange(() => {
                this.toggleSelected(item.uuid)
            })
            .shape(CheckBoxShape.ROUNDED_SQUARE)
    }

    /** 消息列表中的消息气泡 */
    @Builder
    MessageBubble(item: MessageData) {
        Text(item.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.makeBubbleBGColor(item))
            .onClick(() => {
                if (this.isSelectMode) {
                    this.toggleSelected(item.uuid)
                }
            })
            .bindMenu(this.MessageBubbleMenu(item))
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
    }

    @Builder
    MessageBubbleMenu(item: MessageData) {
        if (item.role != 'info' && !this.isSelectMode)
        Menu() {
            ForEach(this.makeBubbleMenuElements(item), (element: MenuElement) => {
                MenuItem({
                    content: element.value,
                    symbolStartIcon: element.symbolIcon,
                    startIcon: element.icon,
                }).onClick(() => {
                    element.action()
                })
            })
        }
    }

    /** 聊天内容气泡的菜单配置 */
    makeBubbleMenuElements(item: MessageData): MenuElement[] {
        return [
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action: () => {
                    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, item.content)
                    this.systemPasteboard.setData(data).then(() => {
                        promptAction.showToast({ message: '复制成功' })
                    }).catch((error: BusinessError) => {
                        promptAction.showToast({ message: `复制失败：${error.message}` })
                    })
                }
            },
            {
                value: '选择文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.selector')),
                action: () => {
                    this.isModalShow = true
                    this.textSelectModalText = item.content
                },
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: async () => {
                    systemShareText(
                        getContext() as common.UIAbilityContext,
                        this.textShareTitle,
                        item.content
                    ).catch((error: BusinessError) => {
                        console.error(error.message)
                    })
                },
            },
            {
                value: this.isSelectMode ? '退出多选' : '批量选择',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    this.isSelectMode = !this.isSelectMode
                    if (this.isSelectMode) {
                        this.dataList = changeAllSelectStatus(this.dataList, false, item.uuid)
                    }
                },
            },
            {
                value: '发送到邮箱',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
                action: () => {
                }
            },
            {
                value: '删除消息',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')),
                action: () => {
                    deleteByUUID(this.dataList, item.uuid)
                },
            },
        ]
    }

    /** 消息列表中的头像 */
    @Builder
    MessageAvatar(item: MessageData) {
        SymbolGlyph(this.makeAvatarSymbolResource(item))
            .fontSize(30)
            .avatarStyles()
            .fontColor([this.makeAvatarSymbolFontColor(item)])
    }

    @Styles
    avatarStyles() {
        .padding(3)
        .borderRadius(10)
        .flexShrink(0)
        .margin({ top: 2 })
        .shadow({ radius: 10, color: $r('sys.color.ohos_id_color_list_separator') })
    }

    makeAvatarSymbolResource(item: MessageData): Resource {
        switch (item.role) {
            case 'user':
                return $r('sys.symbol.person_crop_circle_fill_1')
            case 'info':
                return $r('sys.symbol.flag')
            case 'system':
                return $r('sys.symbol.gearshape')
            case 'assistant':
                return $r('sys.symbol.lightbulb')
            default:
                throw new Error('role not allow')
        }
    }

    makeAvatarSymbolFontColor(item: MessageData): ResourceColor {
        switch (item.role) {
            case 'user':
                return Color.Pink
            case 'info':
                return Color.Orange
            case 'system':
                return Color.Black
            case 'assistant':
                return Color.Gray
            default:
                throw new Error('role not allow')
        }
    }

    makeJustifyContent(item: MessageData) {
        switch (item.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }

    toggleSelected(uuid: string) {
        for (let i = 0; i < this.dataList.length; i++) {
            if (uuid == this.dataList[i].uuid) {
                this.dataList[i].selected = !this.dataList[i].selected
                this.dataList[i] = JSON.parse(JSON.stringify(this.dataList[i]))
                return
            }
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(item: MessageData): ResourceColor {
        switch (item.role) {
            case 'user':
                return Color.Pink
            default:
                return 'rgba(220,220,220,0.3)'
        }
    }

    makeDefaultMessageDataList(): MessageData[] {
        return [
            {
                role: 'info',
                content: '我是智能聊天助手，您可以问我任何问题~',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            },
            {
                role: 'system',
                content: '专门面向老年人的生活智能助手，用简单有趣的语言帮助老人解答各种问题。',
                createTime: new Date(),
                hidden: true,
                uuid: util.generateRandomUUID(false),
            }
        ]
    }
}
