import { SymbolGlyphModifier } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import { getSelectableItems, makeTempAdds, MessageData, } from './util'
import { TextSelectModal } from './TextSelectModal'
import { MessageList } from './MessageList'
import { BottomPanel } from './BottomPanel'

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    @State navTitle: string = ''
    /** 消息输入框内容 */
    messageListScroller = new Scroller()
    /** 是否处于多选模式 */
    @Provide isSelectMode: boolean = false
    messageInputController = new TextAreaController()
    /** 消息列表数据 */
    @Provide('messageDataList') messageDataList: MessageData[] = []
    @Provide isModalShow: boolean = false
    @Provide textSelectModalText: string = ''

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.navTitle = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
        this.messageDataList = this.makeDefaultMessageDataList().concat(makeTempAdds())
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                MessageList({
                    scroller: this.messageListScroller,
                    textAreaController: this.messageInputController
                })
                BottomPanel({
                    messageListScroller: this.messageListScroller,
                    textAreaController: this.messageInputController
                })
            }
        }
        .title(this.navTitle)
        .menus(this.makeNavigationMenuItems())
        .bindSheet($$this.isModalShow, this.TextSelectModal(), {
            title: {
                title: '选择文本'
            },
        })
    }

    @Builder
    TextSelectModal() {
        RelativeContainer() {
            TextSelectModal({
                text: this.textSelectModalText,
            })
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

    /** 右上角菜单项配置 */
    makeNavigationMenuItems(): NavigationMenuItem[] {
        if (this.isSelectMode) {
            return []
        }
        return [
            {
                value: '清空当前聊天记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
                isEnabled: getSelectableItems(this.messageDataList).length != 0,
                action: () => {
                    AlertDialog.show({
                        title: $r('app.string.title_text_tip'),
                        message: $r("app.string.ChatPage_clean_messages_tip"),
                        secondaryButton: {
                            value: $r('app.string.button_text_confirm'),
                            style: DialogButtonStyle.HIGHLIGHT,
                            backgroundColor: Color.Red,
                            action: () => {
                                this.messageDataList = this.makeDefaultMessageDataList()
                            }
                        },
                        primaryButton: {
                            value: $r('app.string.button_text_cancel'),
                            action: () => {
                            }
                        }
                    })
                },
            },
            {
                value: '创建新对话',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus'))
            },
            {
                value: '查看 Messages JSON',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.map')),

            }
        ]
    }
}

@Builder
export function PageBuilder() {
    Page()
}