import { changeAllSelectStatus, deleteByUUID, getTextShareTitle, MessageData, systemShareText } from './util'
import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'

/**
 * 消息列表容器
 */
@Component
export struct MessageItem {
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Consume messageDataList: MessageData[]
    /** 文本选择面板要显示的文本 */
    @Consume textSelectModalText: string
    /** 是否处于多选模式 */
    @Consume isSelectMode: boolean
    @Consume isModalShow: boolean
    @ObjectLink data: MessageData

    build() {
        if (!this.data.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(),
        }) {
            if (this.isSelectMode && this.data.role != 'info') {
                this.Checkbox()
                Blank()
            }
            if (this.data.role == 'user') {
                this.Bubble()
                this.Avatar()
            } else {
                this.Avatar()
                this.Bubble()
            }
        }.onClick(() => {
            if (this.isSelectMode) {
                this.data.selected = !this.data.selected
            }
        }).gesture(LongPressGesture().onAction(() => {
            if (!this.isSelectMode) {
                this.showTextSelectModal()
            }
        }))
    }

    /** 进入文本选择模式，打开半屏模态框 */
    showTextSelectModal() {
        this.isModalShow = true
        this.textSelectModalText = this.data.content
    }

    /** 消息多选项 */
    @Builder
    Checkbox() {
        Checkbox()
            .flexShrink(0)
            .select($$this.data.selected)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
    }

    /** 消息列表中的消息气泡 */
    @Builder
    Bubble() {
        Text(this.data.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.makeBubbleBGColor())
            .bindMenu(
                this.data.role != 'info' && !this.isSelectMode
                    ? this.MessageBubbleMenu() : undefined)
            .lineSpacing(LengthMetrics.vp(5))
            .letterSpacing(1)
            .onClick(() => {
                if (this.isSelectMode) {
                    this.data.selected = !this.data.selected
                    this.messageDataList = [...this.messageDataList]
                }
            })
    }

    @Builder
    MessageBubbleMenu() {
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
                    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.data.content)
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
                    this.showTextSelectModal()
                },
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: async () => {
                    systemShareText(
                        getContext() as common.UIAbilityContext,
                        await getTextShareTitle(),
                        this.data.content
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
                        // 这里重复赋值，并且重置了全部的 UUID，是为了保证列表中每一项组件都得到刷新，从而刷新菜单项
                        // 但是这样是不优雅的，需要寻求新的办法去解决
                        this.messageDataList = this.messageDataList.map(item => {
                            item.uuid = util.generateRandomUUID(false)
                            return item
                        })
                        changeAllSelectStatus(this.messageDataList, false, this.data.uuid)
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
                    deleteByUUID(this.messageDataList, this.data.uuid)
                },
            },
        ]
    }

    /** 消息列表中的头像 */
    @Builder
    Avatar() {
        SymbolGlyph(this.makeAvatarSymbolResource())
            .fontSize(30)
            .avatarStyles()
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
        switch (this.data.role) {
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
        switch (this.data.role) {
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
        switch (this.data.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
    }

    /** 聊天内容气泡的背景颜色 */
    makeBubbleBGColor(): ResourceColor {
        switch (this.data.role) {
            case 'user':
                return Color.Pink
            default:
                return 'rgba(220,220,220,0.3)'
        }
    }
}
