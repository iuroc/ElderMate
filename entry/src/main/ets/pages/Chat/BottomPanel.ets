import { LengthMetrics, promptAction, SymbolGlyphModifier, window } from '@kit.ArkUI'
import { ChatCompletionMessageParam } from '../../modules/openai/npm@4.73.1/resources/chat'
import {
    deleteByUUID,
    getSelectedItems,
    getTextShareTitle,
    isAllSelected,
    mergedMessageForSharing,
    MessageData,
    scrollToBottom,
    systemShareText
} from './util'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { OpenAI } from '../../modules/openai/OpenAI'
import { rcp } from '@kit.RemoteCommunicationKit'

@Component
export struct BottomPanel {
    /** 是否正在请求生成内容 */
    @State chatRequesting: boolean = false
    /** 是否处于多选模式 */
    @Consume isSelectMode: boolean
    /** 当前消息列表 */
    @Consume('messageDataList') messageDataList: MessageData[]
    @State inputValue: string = ''
    @Require messageListScroller = new Scroller()
    textAreaController = new TextAreaController()
    /** 流式输出的第一次输出是否已经完成
     *
     * 改值在每次新请求开始时变为 `true`，第一次接收到流数据后变为 `false` */
    private showRequestStartTip = false
    private requestStartTip = '正在思考~'
    private requestSession?: rcp.Session

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
            let newSelectedStatus = !isAllSelected(this.messageDataList)
            this.messageDataList.forEach(item => {
                item.selected = newSelectedStatus
            })
        })
        Button('退出多选',
            { buttonStyle: ButtonStyleMode.NORMAL }
        ).fontColor(Color.Red).onClick(() => {
            this.isSelectMode = false
        })
        Button('选中项操作').bindMenu(this.selectPanelMenuElements)
    }

    /** 消息输入框 */
    @Builder
    MessageInput() {
        TextArea({
            placeholder: $r("app.string.ChatPage_placeholder"),
            text: $$this.inputValue,
            controller: this.textAreaController
        })
            .enableKeyboardOnFocus(false)
            .onAppear(async () => {
                const lastWindow = await window.getLastWindow(getContext())
                const handle = (data: number) => {
                    if (data > 0) {
                        this.messageListScroller.scrollEdge(Edge.Bottom)
                    }
                }
                lastWindow.on('keyboardHeightChange', handle)
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
                this.requestSession?.cancel()
                const lestItemIndex = this.messageDataList.length - 1
                const lastItem = this.messageDataList[lestItemIndex]
                if (this.showRequestStartTip) {
                    lastItem.role = 'info'
                    lastItem.content = '已停止回答'
                }
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

    /** 多选模式下，对选中项进行的操作菜单 */
    selectPanelMenuElements: MenuElement[] = [
        {
            value: '复制文本',
            icon: $r('app.media.copy'),
            action: () => {
                const selectedItems = getSelectedItems(this.messageDataList)
                const text = mergedMessageForSharing(selectedItems)
                const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
                pasteboard.getSystemPasteboard()
                    .setData(data)
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
            action: async () => {
                const selectedItems = getSelectedItems(this.messageDataList)
                systemShareText(
                    getContext(),
                    await getTextShareTitle(),
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

    handleSendMessage() {
        if (this.inputValue.trim() == '') {
            return
        }
        const requestMessage = new MessageData({ role: 'user', content: this.inputValue })
        this.messageDataList.push(requestMessage)
        this.inputValue = ''
        this.showRequestStartTip = true
        scrollToBottom(this.messageListScroller)

        // 开始请求
        this.chatRequesting = true
        const requestBodyMessages = this.messageDataList
            .filter(item => item.role != 'info')
            .map<ChatCompletionMessageParam>(item => {
                return {
                    role: item.role as 'user' | 'assistant' | 'system',
                    content: item.content
                }
            })
        const responseMessage = new MessageData({ role: 'assistant', content: this.requestStartTip })
        this.messageDataList.push(responseMessage)
        const openai = new OpenAI({
            apiKey: `sk-7TImgtgJvIK8uhlKA1D230B6F18b4363BcA4Be0d342914F7`,
            baseURL: `https://openkey.cloud/v1`
        })
        const result = openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: requestBodyMessages,
            stream: true
        }, async chunks => {
            const chunkContent = chunks.map(chunk => chunk.choices[0].delta.content || '').join('')
            if (this.showRequestStartTip) {
                this.showRequestStartTip = false
                responseMessage.content = chunkContent
            } else {
                responseMessage.content += chunkContent
            }
            scrollToBottom(this.messageListScroller)
        })
        this.requestSession = result.session
        result.response.then(() => {
            this.chatRequesting = false
        })
    }
}