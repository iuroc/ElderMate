import { BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { BSColor } from '@iuroc/bootstrap5-color/Index'
import { promptAction, window } from '@kit.ArkUI'
import { selectPanelMenuElements } from '../config/selectPanelMenuElements'
import { isAllSelected, selectedItems, } from '../utils/utils'
import { MessageData } from './MessageListItem'
import { preferences, relationalStore } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { OpenAI } from '@iuroc/openai'
import { ChatCompletionMessageParam } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources'
import { OnDataCallback, OnErrorCallback } from '@iuroc/openai/src/main/ets/ChatCompletions'
import { ChatData, insertMessage, updateMessage } from '../utils/db'

@Component
export struct BottomPanel {
    @Consume inputMessage: string
    @State paddingBottom: number = 0
    @Consume messageDataList: MessageData[]
    @Consume themeColor: BSColorNameMap
    @Consume pathInfos: NavPathStack
    @Consume isSelectMode: boolean
    @Require messageListScroller: Scroller = Object()
    @Consume isChatRequesting: boolean
    @Consume dataPreferences: preferences.Preferences
    /** 是否显示请求开始时的提示文本，比如：正在思考
     *
     * 该值在每次新请求开始时变为 `true`，第一次接收到流数据后变为 `false` */
    private showRequestStartTip = false
    /** 第一次流式响应之前显示的提示文本 */
    private requestStartTip = '正在思考~'
    private requestSession: rcp.Session = Object()
    @Consume openaiApiKey: string
    @Consume openaiBaseURL: string
    @Consume chatDataList: ChatData[]
    @Consume rdbStore: relationalStore.RdbStore
    @Consume currentChatIndex: number
    @Consume autoScrollToBottom: boolean
    @Require updateCurrentChat: (values: relationalStore.ValuesBucket) => void = Object()
    @Consume defaultChatTitle: string

    aboutToDisappear(): void {
        this.updateLatestMessage()
    }

    async aboutToAppear() {
        const lastWindow = await window.getLastWindow(getContext())
        lastWindow.on('keyboardHeightChange', height => {
            // 判断处于 Chat 页面，因为其他页面也会触发该事件，他们属于同一个 window
            if (this.pathInfos.getAllPathName().slice(-1)[0] == 'Chat') {
                // 在键盘抬高时，设置底部面板的底边距
                this.paddingBottom = height > 0 ? 10 : 0
                // 在键盘抬高时，让列表滚动到底部
                this.messageListScroller.scrollEdge(Edge.Bottom)
            }
        })
    }

    build() {
        Row({ space: 10 }) {
            if (this.isSelectMode) {
                // 多选状态下的底部操作面板
                this.SelectPanel()
            } else {
                // 消息输入框
                this.MessageInput()
                if (this.isChatRequesting) {
                    // 取消生成按钮
                    this.CancelGenerate()
                } else {
                    // 消息发送按钮
                    this.SendButton()
                }
            }
        }
        .padding({
            left: 10,
            right: 10,
            top: 10,
            bottom: this.paddingBottom
        })
        .border({
            width: { top: 1, },
            color: BSColor.light
        })
    }

    /** 多选状态下的底部操作面板 */
    @Builder
    SelectPanel() {
        Button((isAllSelected(this.messageDataList) ? $r('app.string.deselect_all') : $r('app.string.select_all')))
            .onClick(() => {
                const newSelectedStatus = !isAllSelected(this.messageDataList)
                this.messageDataList.forEach(item => item.selected = newSelectedStatus)
            })
            .backgroundColor(
                isAllSelected(this.messageDataList) ? BSColor.warning_bg_subtle : BSColor.success_bg_subtle
            )
            .fontColor(
                isAllSelected(this.messageDataList) ? BSColor.warning_text_emphasis : BSColor.success_text_emphasis
            )
        Button($r('app.string.exit_multi_select'), { buttonStyle: ButtonStyleMode.NORMAL })
            .fontColor(getColorGroup(this.themeColor).main)
            .onClick(() => {
                this.quitSelectMode()
            })
        Button($r('app.string.selected_item_actions'))
            .backgroundColor(getColorGroup(this.themeColor).main)
            .bindMenu(selectPanelMenuElements(this))
            .enabled(selectedItems(this.messageDataList).length > 0)
    }

    quitSelectMode() {
        this.isSelectMode = false
        this.messageDataList.forEach(item => item.selected = false)
    }

    mergeSelectedContent() {
        return selectedItems(this.messageDataList)
            .map(item => `【${item.role}】\n${item.content}`).join('\n')
    }

    /** 消息输入框 */
    @Builder
    MessageInput() {
        TextArea({
            text: $$this.inputMessage,
            placeholder: $r('app.string.placeholder'),
        })
            .layoutWeight(1)
            .enableKeyboardOnFocus(false)
    }

    /** 消息发送按钮 */
    @Builder
    SendButton() {
        Button($r('app.string.button_send'))
            .enabled(this.inputMessage.trim() != '')
            .backgroundColor(getColorGroup(this.themeColor).main)
            .onClick(() => {
                this.handleMessageSend()
            })
            .alignSelf(ItemAlign.End)
    }

    /** 停止生成按钮 */
    @Builder
    CancelGenerate() {
        Button($r('app.string.cancel_generation'), {
            buttonStyle: ButtonStyleMode.NORMAL,
        })
            .fontColor(Color.Black)
            .onClick(() => {
                // 停止正在生成状态
                this.isChatRequesting = false
                // 停止网络请求
                this.requestSession.cancel()
                this.updateLatestMessage()
            })
            .flexShrink(0)
    }

    /**
     * 保存 message 的最新状态
     *
     * 在请求完成、手动停止请求、页面销毁导致请求停止时，都需要调用此方法保存 message 的最新状态
     */
    updateLatestMessage() {
        // 最新一条消息列表项的下标
        const lestItemIndex = this.messageDataList.length - 1
        // 最新一条消息列表项
        const lastItem = this.messageDataList[lestItemIndex]
        // 更新数据库中的 message 记录为最新的响应状态
        updateMessage(this.rdbStore, {
            content: lastItem.content,
            role: lastItem.role,
        }, lastItem.id)
    }

    handleMessageSend() {
        // 检查 OpenAI 配置是否完整
        if (!this.openaiBaseURL || !this.openaiApiKey) {
            promptAction.showToast({ message: 'OpenAI 配置不完整' })
            return
        }
        /** 最终需要发送的消息内容 */
        const messageWillSend = this.inputMessage.trim()
        // 清空消息输入框
        this.inputMessage = ''
        this.autoScrollToBottom = true
        /** 包含在 Request 里的 MessageData */
        const requestMessageData = new MessageData({
            role: 'user',
            content: messageWillSend,
            inRequest: true,
        })
        // 将新产生的 Message 插入到数据库，并更新 latestId
        requestMessageData.id = insertMessage(
            this.rdbStore,
            this.chatDataList[this.currentChatIndex].id,
            requestMessageData)
        // 将需要发送的消息添加到页面列表
        this.messageDataList.push(requestMessageData)

        // 更新当前 chat 的标题为第一次 role=user 的消息的前 10 字
        if (this.messageDataList.filter(i => i.role == 'user' && !i.hidden).length == 1 &&
            this.chatDataList[this.currentChatIndex].title == this.defaultChatTitle) {
            const newTitle = requestMessageData.content.slice(0, 10)
            this.updateCurrentChat({
                title: newTitle
            })
            this.chatDataList[this.currentChatIndex].title = newTitle
        }

        // 包含在响应中的 MessageData 的容器
        const responseMessageData = new MessageData({
            role: 'assistant',
            content: this.requestStartTip,
            inRequest: true,
        })
        responseMessageData.id = insertMessage(
            this.rdbStore,
            this.chatDataList[this.currentChatIndex].id,
            responseMessageData
        )
        this.messageDataList.push(responseMessageData)
        /** 开始请求中状态 */
        this.isChatRequesting = true
        /** 显示正在思考 */
        this.showRequestStartTip = true
        /** 循环拼接来自响应的 `content` 字符串 */
        let textContent = ''

        const onData: OnDataCallback = chunks => {
            const newContent = chunks.map(chunk => chunk.choices[0].delta.content).join('')
            if (this.showRequestStartTip) {
                textContent = newContent
                this.showRequestStartTip = false
            } else {
                textContent += newContent
            }
            responseMessageData.content = textContent
        }

        const onError: OnErrorCallback = error => {
            if (error.message == 'Request is canceled') {
                if (this.showRequestStartTip) {
                    responseMessageData.content = '已停止回答'
                } else {
                    return
                }
            } else {
                responseMessageData.content = error.message
            }
            responseMessageData.role = null
            this.updateLatestMessage()
            this.isChatRequesting = false
        }

        /** OpenAI 请求工具对象 */
        const openai = new OpenAI({
            apiKey: this.openaiApiKey,
            baseURL: this.openaiBaseURL
        })
        const result = openai.chat.completions.create({
            model: this.chatDataList[this.currentChatIndex].model,
            messages: this.messageDataList.filter(item => item.role as string).map(item => {
                return {
                    role: item.role,
                    content: item.content
                } as ChatCompletionMessageParam
            }),
            stream: true
        }, {
            onData,
            onError,
            requestConfiguration: {
                proxy: 'system',
                security: {
                    remoteValidation: 'skip'
                },
                transfer: {
                    timeout: {
                        connectMs: 10000
                    }
                }
            },
        })

        this.requestSession = result.session
        result.response.then(_result => {
            this.isChatRequesting = false
            // 更新 message 记录的 content 值
            this.updateLatestMessage()
        })
    }
}