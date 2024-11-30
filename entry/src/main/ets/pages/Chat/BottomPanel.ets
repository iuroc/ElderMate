import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { ChatCompletionMessageParam } from '../../modules/openai/npm@4.73.1/resources/chat'
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
import { util } from '@kit.ArkTS'
import { OpenAI } from '../../modules/openai/OpenAI'

@Component
export struct BottomPanel {
    /** 是否正在请求生成内容 */
    @State chatRequesting: boolean = false
    /** 是否处于多选模式 */
    @Link isSelectMode: boolean
    /** 当前消息列表 */
    @Link messageDataList: MessageData[]
    @Prop inputValue: string = ''
    @Require @Prop textShareTitle: string = ''
    @Require messageListScroller = new Scroller()
    @Require textAreaController = new TextAreaController()
    systemPasteboard = pasteboard.getSystemPasteboard()

    build() {
        Flex({
            space: { main: LengthMetrics.vp(10) },
            justifyContent: FlexAlign.Center,
            alignItems: ItemAlign.End
        }) {
            if (this.isSelectMode) {
                // 多选模式操作面板
                this.SelectPanel()
            } else {
                // 消息输入框
                this.MessageInput()
                if (this.chatRequesting) {
                    // 取消生成按钮
                    this.CancelGenerate()
                } else {
                    // 消息发送按钮
                    this.SendButton()
                }
            }
        }
        .padding(10)
    }

    @Builder
    SelectPanel() {
        Button(isAllSelected(this.messageDataList) ? '全不选' : '全选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).onClick(() => {
            this.messageDataList = changeAllSelectStatus(
                this.messageDataList,
                !isAllSelected(this.messageDataList)
            )
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

    /** 停止生成按钮 */
    @Builder
    CancelGenerate() {
        Button('取消生成', {
            buttonStyle: ButtonStyleMode.NORMAL,
        })
            .fontColor(Color.Black)
            .onClick(() => {
                this.chatRequesting = false
                const lestItemIndex = this.messageDataList.length - 1
                const lestItem = this.messageDataList[lestItemIndex]
                if (lestItem.content == '' || lestItem.content == '正在思考~') {
                    lestItem.role = 'info'
                    lestItem.content = '已停止回答'
                }
                this.messageDataList[lestItemIndex] = JSON.parse(JSON.stringify(lestItem))
            })
            .flexShrink(0)
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

        // 开始请求
        this.chatRequesting = true
        const requestMessages = this.messageDataList
            .map<ChatCompletionMessageParam | undefined>(item => {
                return item.role != 'info' ? {
                    role: item.role,
                    content: item.content,
                } : undefined
            }).filter(item => item) as ChatCompletionMessageParam[]

        const response: MessageData = {
            role: 'assistant',
            content: '正在思考~',
            createTime: new Date(),
            uuid: util.generateRandomUUID(false),
            hidden: false,
            selected: false,
        }
        this.messageDataList.push(response)
        const openai = new OpenAI({
            apiKey: `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`,
            baseURL: `https://openkey.cloud/v1`
        })
        let allContent = ''
        openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: requestMessages,
            stream: true
        }, async chunks => {
            if (!this.chatRequesting) {
                return // 中途手动停止了
            }
            allContent += chunks.map(chunk => chunk.choices[0].delta.content || '').join('')
            response.content = allContent
            this.messageDataList[this.messageDataList.length - 1] = JSON.parse(JSON.stringify(response))
            scrollToBottom(this.messageListScroller)
        }).then(() => {
            this.chatRequesting = false
        })
    }
}