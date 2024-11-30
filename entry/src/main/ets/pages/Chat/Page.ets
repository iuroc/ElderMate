import { SymbolGlyphModifier } from '@kit.ArkUI'
import { getSelectableItems, makeTempAdds, MessageData, } from './util'
import { TextSelectModal } from './TextSelectModal'
import { MessageList } from './MessageList'
import { BottomPanel } from './BottomPanel'

@Component
struct Page {
    @Consume pathInfos: NavPathStack
    @State navTitle: string = ''
    /** 消息输入框内容 */
    messageListScroller = new Scroller()
    messageInputController = new TextAreaController()
    /** 是否处于多选模式 */
    @Provide isSelectMode: boolean = false
    /** 消息列表数据 */
    @Provide messageDataList: MessageData[] = this.makeDefaultMessageDataList().concat(makeTempAdds())
    @Provide isModalShow: boolean = false
    /** 文本选择面板要显示的文本 */
    @Provide textSelectModalText: string = ''

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.navTitle = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
        // this.pathInfos.pushPath({ name: 'Test' })
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                // 消息列表
                MessageList({
                    scroller: this.messageListScroller,
                    textAreaController: this.messageInputController
                })
                // 底部操作面板
                BottomPanel({
                    messageListScroller: this.messageListScroller,
                    textAreaController: this.messageInputController,
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

    /** 文本选择面板 */
    @Builder
    TextSelectModal() {
        RelativeContainer() {
            TextSelectModal({
                text: this.textSelectModalText,
            })
        }
    }

    /** 生成默认的消息列表 */
    makeDefaultMessageDataList(): MessageData[] {
        return [
            new MessageData({ role: 'info', content: '我是智能聊天助手，您可以问我任何问题~' }),
            new MessageData({
                role: 'system',
                content: '你是一个智能老年人生活助手，你的职责是帮助老年人解答生活中遇到的各种问题，并以亲切有趣的风格生成适合老年人的回答。',
                hidden: true,
            })
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
                action: () => {
                    this.pathInfos.pushPath({ name: 'Test' })
                }
            }
        ]
    }
}

@Builder
export function PageBuilder() {
    Page()
}