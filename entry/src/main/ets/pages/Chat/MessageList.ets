import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { it } from '@ohos/hypium'
import { Page as ChatPage } from './Page'
import { scrollToBottom } from './util'

@Component
export struct MessageList {
    scroller = new Scroller()
    @Link messageDataList: MessageData[]
    /** 是否处于多选模式 */
    @Link selectMode: boolean
    textAreaController = new TextAreaController()

    onDidBuild(): void {
        setTimeout(() => {
            this.scroller.scrollEdge(Edge.Bottom)
        }, 150)
    }

    build() {
        Scroll(this.scroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (item: MessageData) => {
                    this.MessageItem(item)
                })
            }
            .margin(20)
        }
        .align(Alignment.Top)
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
    }

    /**
     * 消息列表中的头像
     * @param symbolIcon
     */
    @Builder
    Avatar(item: MessageData) {
        SymbolGlyph(this.makeAvatarSymbolResource(item))
            .fontSize(30)
            .padding(3)
            .borderRadius(10)
            .flexShrink(0)
            .margin({ top: 2 })
            .shadow({ radius: 10, color: $r('sys.color.ohos_id_color_list_separator') })
    }

    /**
     * 消息列表项，包含头像和消息气泡
     * @param item 消息列表项数据
     */
    @Builder
    MessageItem(item: MessageData) {
        if (!item.hidden)
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: this.makeJustifyContent(item),
        }) {
            if (this.selectMode && item.role != 'info') {
                Checkbox()
                    .flexShrink(0)
                    .select(item.selected)
                    .onChange(() => {
                        this.toggleSelected(item.uuid)
                    })
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                Blank()
            }
            if (item.role == 'user') {
                this.Bubble(item)
                this.Avatar(item)
            } else {
                this.Avatar(item)
                this.Bubble(item)
            }
        }
        .onClick(() => {
            if (this.selectMode) {
                this.toggleSelected(item.uuid)
            }
        })
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

    makeJustifyContent(item: MessageData) {
        switch (item.role) {
            case 'user':
                return FlexAlign.End
            default:
                return FlexAlign.Start
        }
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

    richEditorController = new RichEditorController()

    /**
     * 消息列表中的消息气泡
     * @param item
     */
    @Builder
    Bubble(item: MessageData) {
        Text(item.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.makeBubbleBGColor(item))
            .bindMenu(this.BubbleMenu(item))
            .onTouch(event => {
                if (event.type == TouchType.Down) {
                    this.textAreaController.stopEditing()
                }
            })
            .onClick(() => {
                if (this.selectMode) {
                    this.toggleSelected(item.uuid)
                }
            })
    }

    @Builder
    BubbleMenu(item: MessageData) {
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

                }
            },
            {
                value: '选择文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.selector')),
                action: () => {

                },
            },
            {
                value: '分享文本',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: () => {

                },
            },
            {
                value: this.selectMode ? '退出多选' : '批量选择',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_checkmask')),
                action: () => {
                    if (this.selectMode) {
                        quitSelectMode(this)
                    } else {
                        openSelectMode(this)
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

/**
 * 消息列表项数据
 */
export interface MessageData {
    /** 消息角色，如果是 `info
     ` 则不会参与文本生成 */
    role: 'user' | 'assistant' | 'system' | 'info'
    content: string
    /** 默认请设置为 `new

     Date()

     ` */
    createTime: Date
    hidden?: boolean
    /** 请使用 `util
     .generateRandomUUID(false)

     ` 生成 */
    uuid: string
    selected?: boolean
}

/**
 * 设置全选或全不选，并设置全部是否处于多选模式
 * @param component
 * @param selected
 * @param selectMode
 */
export function changeAllSelectStatus(component: MessageList | ChatPage, selected: boolean) {
    component.messageDataList = component.messageDataList.map(item => {
        item.selected = selected
        return item
    })
}

/** 进入多选模式 */
function openSelectMode(component: MessageList | ChatPage) {
    component.selectMode = true
}

/** 退出多选模式 */
export function quitSelectMode(component: MessageList | ChatPage) {
    component.selectMode = false
    changeAllSelectStatus(component, false)
}

/** 删除指定 `UUID` 的消息 */
export function deleteByUUID(component: MessageList | ChatPage, uuid: string) {
    for (let i = 0; i < component.messageDataList.length; i++) {
        if (component.messageDataList[i].uuid == uuid) {
            component.messageDataList.splice(i, 1)
            return
        }
    }
}

/**
 * 当前可见项目是否全部选中状态（不包含 `hidden=true` 和 `role=info` 的项目）
 * @param component
 * @returns
 */
export function isAllSelected(component: MessageList | ChatPage) {
    return component.messageDataList.filter(item => {
        return !item.selected && item.role != 'info' && !item.hidden
    }).length == 0
}