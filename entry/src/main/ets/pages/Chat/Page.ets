import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import {
    changeAllSelectStatus,
    deleteByUUID,
    getSelectedItems,
    isAllSelected,
    mergedMessageForSharing,
    MessageData,
    scrollToBottom,
    systemShareText
} from './util'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { TextSelectModal } from './TextSelectModal'
import { MessageList } from './MessageList'

@Component
export struct Page {
    @Consume pathInfos: NavPathStack
    title: string = ''
    /** 消息输入框内容 */
    @State inputValue: string = ''
    messageListScroller = new Scroller()
    /** 是否正在请求生成内容 */
    @State chatRequesting: boolean = false
    /** 是否处于多选模式 */
    @State selectMode: boolean = false
    textAreaController = new TextAreaController()
    /** 消息列表数据 */
    @State messageDataList: MessageData[] = this.getDefaultMessageDataList()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @State isModalShow: boolean = false
    @State textSelectModalText: string = ''
    textShareTitle: string = ''

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.title = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
        this.textShareTitle = await resourceManager.getStringValue(
            $r('app.string.ChatPage_TextSelectModal_text_share_title')
        )
        this.messageDataList.push(...this.tempAdds)
    }

    onDidBuild(): void {
        setTimeout(() => {
            this.messageListScroller.scrollEdge(Edge.Bottom)
        }, 200)
    }

    build() {
        NavDestination() {
            Flex({ direction: FlexDirection.Column }) {
                MessageList({
                    messageDataList: this.messageDataList,
                    textSelectModalText: this.textSelectModalText,
                    selectMode: this.selectMode,
                    isModalShow: this.isModalShow,
                    scroller: this.messageListScroller
                })
                Flex({
                    space: { main: LengthMetrics.vp(10) },
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.End
                }) {
                    if (this.selectMode) {
                        this.SelectPanel()
                    } else {
                        this.MessageInput()
                        this.SendButton()
                    }
                }
                .padding(10)
            }
        }
        .title(this.title)
        .menus(this.getMenuItems())
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

    @Builder
    SelectPanel() {
        Button(isAllSelected(this.messageDataList) ? '全不选' : '全选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).onClick(() => {
            changeAllSelectStatus(this, !isAllSelected(this.messageDataList))
        })
        Button('退出多选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).fontColor(Color.Red).onClick(() => {
            this.selectMode = false
        })
        Button('选中项操作').bindMenu(this.selectPanelMenuElements)
    }

    /** 多选模式下，对选中项进行的操作菜单 */
    selectPanelMenuElements: MenuElement[] = [
        {
            value: '复制文本',
            icon: $r('app.media.copy'),
            action: () => {
                const selectedItems = getSelectedItems(this.messageDataList)
                const text = mergedMessageForSharing(selectedItems)
                const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
                this.systemPasteboard.setData(data)
                    .then(() => {
                        promptAction.showToast({ message: `复制成功` })
                    })
                    .catch((error: BusinessError) => {
                        promptAction.showToast({ message: `复制失败：${error.message}` })
                    })
                    .finally(() => {
                        this.selectMode = false // 退出多选模式
                    })
            }
        },
        {
            value: '分享文本',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
            action: () => {
                const selectedItems = getSelectedItems(this.messageDataList)
                systemShareText(
                    getContext(),
                    this.textShareTitle,
                    mergedMessageForSharing(selectedItems)
                ).catch((error: BusinessError) => {
                    promptAction.showToast({ message: `分享失败：${error.message}` })
                }).finally(() => {
                    this.selectMode = false // 退出多选模式
                })
            },
        },
        {
            value: '删除消息',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')),
            action: () => {
                AlertDialog.show({
                    message: $r('app.string.ChatPage_delete_selected_messages_tip'),
                    title: $r('app.string.title_text_tip'),
                    primaryButton: {
                        value: $r('app.string.button_text_cancel'),
                        action() {
                        }
                    },
                    secondaryButton: {
                        value: $r('app.string.button_text_confirm'),
                        style: DialogButtonStyle.HIGHLIGHT,
                        backgroundColor: Color.Red,
                        action: () => {
                            getSelectedItems(this.messageDataList).forEach(item => {
                                deleteByUUID(this, item.uuid)
                            })
                            this.selectMode = false
                        }
                    }
                })
            }
        },
        {
            value: '发送到邮箱',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.envelope')),
            action: () => {
            }
        },
    ]

    /** 消息输入框 */
    @Builder
    MessageInput() {
        TextArea({
            placeholder: $r("app.string.ChatPage_placeholder"),
            text: this.inputValue,
            controller: this.textAreaController
        })
            .enableKeyboardOnFocus(false)
            .onChange(value => {
                this.inputValue = value
            })
            .onEditChange(_isEditing => {
                if (_isEditing) {
                    // 进入编辑状态后，取消多选状态
                    this.selectMode = false
                }
                // 这里是个隐患，在软键盘抬起的同时让滚动区域滚到底部，需要设置一个时间去等待软键盘完全抬起，否则将无法正常跳转底部
                // 稳妥的做法是等待软键盘完全抬起，再滚动到底部，否则在软键盘完全抬起之前会滚动到错误的底部，软件就以为那里就是最底部了
                setTimeout(() => {
                    this.messageListScroller.scrollEdge(Edge.Bottom)
                }, 150)
            })
    }

    /** 消息发送按钮 */
    @Builder
    SendButton() {
        Button($r("app.string.ChatPage_button_text_send"), {
            stateEffect: this.inputValue.trim() != '',
            buttonStyle: this.inputValue.trim() != '' ? ButtonStyleMode.EMPHASIZED : ButtonStyleMode.NORMAL
        })
            .onClick(() => {
                this.handleSendMessage()
            })
            .flexShrink(0)
    }

    getDefaultMessageDataList(): MessageData[] {
        return [
            {
                role: 'info',
                content: '我是智能聊天助手，您可以问我任何问题~',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            }
        ]
    }

    richEditorController = new RichEditorController()

    handleSendMessage() {
        if (this.inputValue.trim() == '') {
            return
        }
        this.messageDataList.push({
            role: 'user',
            content: this.inputValue.trim(),
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
            hidden: false,
            selected: false,
        })
        this.inputValue = ''
        scrollToBottom(this.messageListScroller)
    }

    /** 右上角菜单项配置 */
    getMenuItems(): NavigationMenuItem[] {
        return this.selectMode ? [] : [
            {
                value: '清空当前聊天记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.clean')),
                action: () => {
                    AlertDialog.show({
                        title: $r('app.string.title_text_tip'),
                        message: $r("app.string.ChatPage_clean_messages_tip"),
                        secondaryButton: {
                            value: $r('app.string.button_text_confirm'),
                            style: DialogButtonStyle.HIGHLIGHT,
                            backgroundColor: Color.Red,
                            action: () => {
                                this.messageDataList = this.getDefaultMessageDataList()
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
        ]
    }

    tempAdds: MessageData[] = [
        {
            role: 'system',
            content: '你是一个智能老年人生活助手，你的职责是帮助老年人解答生活中遇到的各种问题，并以亲切有趣的风格生成适合老年人的回答。',
            createTime: new Date(),
            hidden: true,
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'user',
            content: '今天的天气怎么样？',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'assistant',
            content: '今天阳光明媚，气温在25度左右，非常适合外出活动。',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'user',
            content: '你有没有推荐的好书或者电影，可以分享一下你的感受吗？',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'assistant',
            content: '最近我读了一本很不错的书，叫《追风筝的人》。这本书讲述了友谊和背叛的故事，情感非常细腻，让我感触很深。我推荐你也去看看。同时，最近看的电影《摔跤吧！爸爸》也很有启发性，它展现了一个父亲为了支持女儿追求梦想所付出的努力，非常感人。',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'user',
            content: '你平时喜欢做哪些运动来保持健康？',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        },
        {
            role: 'assistant',
            content: '我平时最喜欢的运动是跑步和游泳。每周我都会尽量去跑步三次，大约30分钟到一个小时，感觉非常放松。而游泳则是我喜欢的夏季运动，它不仅锻炼全身肌肉，还能让我在水中感受到凉爽，尤其是在炎热的天气里。',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
        }
    ]
}

