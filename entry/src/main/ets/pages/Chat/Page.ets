import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import {
    changeAllSelectStatus,
    deleteByUUID,
    getSelectableItems,
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
    @State title: string = ''
    /** 消息输入框内容 */
    @State inputValue: string = ''
    messageListScroller = new Scroller()
    /** 是否正在请求生成内容 */
    @State chatRequesting: boolean = false
    /** 是否处于多选模式 */
    @State isSelectMode: boolean = false
    textAreaController = new TextAreaController()
    /** 消息列表数据 */
    @State messageDataList: MessageData[] = this.makeDefaultMessageDataList()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @State isModalShow: boolean = false
    @State textSelectModalText: string = ''
    @State textShareTitle: string = ''

    async aboutToAppear() {
        const context = getContext()
        const resourceManager = context.resourceManager
        this.title = await resourceManager.getStringValue($r('app.string.ChatPage_title'))
        this.textShareTitle = await resourceManager.getStringValue(
            $r('app.string.ChatPage_TextSelectModal_text_share_title')
        )
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
                    isSelectMode: this.isSelectMode,
                    isModalShow: this.isModalShow,
                    scroller: this.messageListScroller,
                    textShareTitle: this.textShareTitle
                })
                Flex({
                    space: { main: LengthMetrics.vp(10) },
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.End
                }) {
                    if (this.isSelectMode) {
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
            this.isSelectMode = false
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
                        this.isSelectMode = false // 退出多选模式
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
                    this.isSelectMode = false // 退出多选模式
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
                                deleteByUUID(this.messageDataList, item.uuid)
                            })
                            this.isSelectMode = false
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
                    this.isSelectMode = false
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
            buttonStyle: ButtonStyleMode.EMPHASIZED
        })
            .enabled(this.inputValue.trim() != '')
            .onClick(() => {
                this.handleSendMessage()
            })
            .flexShrink(0)
    }

    makeDefaultMessageDataList(): MessageData[] {
        return [
            {
                role: 'info',
                content: '我是智能聊天助手，您可以问我任何问题~',
                createTime: new Date(),
                uuid: util.generateRandomUUID(false),
            }
        ]
    }

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

            },
            {
                value: '关于本项目',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.info_circle')),
                action: () => {
                    AlertDialog.show({
                        title: '关于本项目',
                        message: $r('app.string.about_project')
                    })
                }
            }
        ]
    }
}