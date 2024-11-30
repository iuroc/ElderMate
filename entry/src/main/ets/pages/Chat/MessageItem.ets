import { changeAllSelectStatus, deleteByUUID, getTextShareTitle, MessageData, systemShareText } from './util'
import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

/**
 * 消息列表容器
 */
@Component
export struct MessageItem {
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Consume('messageDataList') dataList: MessageData[]
    @Consume textSelectModalText: string
    /** 是否处于多选模式 */
    @Consume isSelectMode: boolean
    @Consume isModalShow: boolean
    @ObjectLink messageData: MessageData

    build() {
        if (!this.messageData.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(),
        }) {
            if (this.isSelectMode && this.messageData.role != 'info') {
                this.MessageCheckbox()
                Blank()
            }
            if (this.messageData.role == 'user') {
                this.Bubble()
                this.Avatar()
            } else {
                this.Avatar()
                this.Bubble()
            }
        }.onClick(() => {
            if (this.isSelectMode) {
                this.toggleSelected()
            }
        })
    }

    /** 消息多选项 */
    @Builder
    MessageCheckbox() {
        Checkbox()
            .flexShrink(0)
            .select(this.messageData.selected)
            .onChange(() => {
                this.toggleSelected()
            })
            .shape(CheckBoxShape.ROUNDED_SQUARE)
    }

    /** 消息列表中的消息气泡 */
    @Builder
    Bubble() {
        Text(this.messageData.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.makeBubbleBGColor())
            .onClick(() => {
                if (this.isSelectMode) {
                    this.toggleSelected()
                }
            })
            .bindMenu(this.MessageBubbleMenu())
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
    }

    @Builder
    MessageBubbleMenu() {
        if (this.messageData.role != 'info' && !this.isSelectMode)
        Menu() {
            ForEach(this.makeBubbleMenuElements(), (element: MenuElement) => {
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
    makeBubbleMenuElements(): MenuElement[] {
        return [
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action: () => {
                    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.messageData.content)
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
                    this.textSelectModalText = this.messageData.content
                },
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: async () => {
                    systemShareText(
                        getContext() as common.UIAbilityContext,
                        await getTextShareTitle(),
                        this.messageData.content
                    ).catch((error: BusinessError) => {
                        AlertDialog.show({ message: `分享失败：${error.message}` })
                    })
                },
            },
            {
                value: this.isSelectMode ? '退出多选' : '批量选择',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    this.isSelectMode = !this.isSelectMode
                    if (this.isSelectMode) {
                        this.dataList = changeAllSelectStatus(this.dataList, false, this.messageData.uuid)
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
                    deleteByUUID(this.dataList, this.messageData.uuid)
                },
            },
        ]
    }

    /** 消息列表中的头像 */
    @Builder
    Avatar() {
        SymbolGlyph(this.makeAvatarSymbolResource())
            .fontSize(30)// .avatarStyles()
            .fontColor([this.makeAvatarSymbolFontColor()])
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
        switch (this.messageData.role) {
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

    makeAvatarSymbolFontColor(): ResourceColor {
        switch (this.messageData.role) {
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

    makeJustifyContent() {
        switch (this.messageData.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }

    toggleSelected() {
        for (let i = 0; i < this.dataList.length; i++) {
            if (this.messageData.uuid == this.dataList[i].uuid) {
                this.dataList[i].selected = !this.dataList[i].selected
                this.dataList[i] = JSON.parse(JSON.stringify(this.dataList[i]))
                return
            }
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(): ResourceColor {
        switch (this.messageData.role) {
            case 'user':
                return Color.Pink
            default:
                return 'rgba(220,220,220,0.3)'
        }
    }
}
