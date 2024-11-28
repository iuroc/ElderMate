import { changeAllSelectStatus, deleteByUUID, MessageData, systemShareText } from "./util"
import { LengthMetrics, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { BusinessError, pasteboard } from "@kit.BasicServicesKit"
import { common } from "@kit.AbilityKit"

/**
 * 消息列表容器
 */
@Component
export struct MessageList {
    scroller = new Scroller()
    textAreaController = new TextAreaController()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Link messageDataList: MessageData[]
    @Link textSelectModalText: string
    /** 是否处于多选模式 */
    @Link selectMode: boolean
    @Link isModalShow: boolean
    @Prop textShareTitle: string = ''

    build() {
        Scroll(this.scroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (item: MessageData) => {
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
    }

    /** 消息列表项，包含头像和消息气泡 */
    @Builder
    MessageItem(item: MessageData) {
        if (!item.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(item),
        }) {
            if (this.selectMode && item.role != 'info') {
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
            if (this.selectMode) {
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
                if (this.selectMode) {
                    this.toggleSelected(item.uuid)
                }
            })
            .bindMenu(this.MessageBubbleMenu(item))
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
    }

    @Builder
    MessageBubbleMenu(item: MessageData) {
        if (item.role != 'info' && !this.selectMode)
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
                value: this.selectMode ? '退出多选' : '批量选择',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    this.selectMode = !this.selectMode
                    if (this.selectMode) {
                        changeAllSelectStatus(this, false, item.uuid)
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
                    deleteByUUID(this, item.uuid)
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
        for (let i = 0; i < this.messageDataList.length; i++) {
            if (uuid == this.messageDataList[i].uuid) {
                this.messageDataList[i].selected = !this.messageDataList[i].selected
                this.messageDataList[i] = JSON.parse(JSON.stringify(this.messageDataList[i]))
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
}
