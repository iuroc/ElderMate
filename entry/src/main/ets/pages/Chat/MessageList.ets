import { LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { inputMethod, inputMethodEngine } from "@kit.IMEKit"
import { util } from "@kit.ArkTS"

@Component
export struct MessageList {
    scroller = new Scroller()
    @Link messageDataList: MessageData[]

    aboutToAppear(): void {

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
        .onTouch((event) => {
            if (event.type == 0) {
                // const controller = inputMethod.getController()
                // controller.hideTextInput()
            }
        })
        .align(Alignment.Top)
        .height('100%')
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
            if (item.role == 'user') {
                this.Bubble(item)
                this.Avatar(item)
            } else {
                this.Avatar(item)
                this.Bubble(item)
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
            .bindMenu(this.makeBubbleMenuElements(item))
    }

    /** 聊天内容气泡的菜单配置 */
    makeBubbleMenuElements(item: MessageData): MenuElement[] {
        if (item.role == 'info') {
            return []
        }
        return [
            {
                value: '复制文本',
                icon: $r('app.media.copy'),
                action() {

                }
            },
            {
                value: '删除消息',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')),
                action: () => {
                    this.deleteByUUID(item.uuid)
                },
            }
        ]
    }

    makeBubbleBGColor(item: MessageData): ResourceColor {
        switch (item.role) {
            case 'user':
                return Color.Pink
            default:
                return 'rgba(220,220,220,0.3)'
        }
    }

    deleteByUUID(uuid: string) {
        for (let i = 0; i < this.messageDataList.length; i++) {
            if (this.messageDataList[i].uuid == uuid) {
                this.messageDataList.splice(i, 1)
                return
            }
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
}