import { BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"
import { BSColor } from "@iuroc/bootstrap5-color/Index"
import { window } from "@kit.ArkUI"
import { BooleanValue } from "../utils/utils"
import { MessageData } from "./MessageListItem"

@Component
export struct BottomPanel {
    @Link inputMessage: string
    @State paddingBottom: number = 0
    @Consume messageDataList: MessageData[]
    @Consume themeColor: BSColorNameMap
    messageListScroller?: Scroller
    @Consume pathInfos: NavPathStack
    @Require nextSizeChangeNeedScrollToBottom?: BooleanValue
    @Require textAreaController?: TextAreaController

    async aboutToAppear() {
        const lastWindow = await window.getLastWindow(getContext())
        lastWindow.on('keyboardHeightChange', height => {
            // 判断处于 Chat 页面，因为其他页面也会触发该事件，他们属于同一个 window
            if (this.pathInfos.getAllPathName().slice(-1)[0] == 'Chat') {
                // 在键盘抬高时，设置底部面板的底边距
                this.paddingBottom = height > 0 ? 10 : 0
                // 在键盘抬高时，让列表滚动到底部
                this.messageListScroller?.scrollEdge(Edge.Bottom)
            }
        })
    }

    build() {
        Row({ space: 10 }) {
            this.MessageInput()
            this.SendButton()
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

    @Builder
    MessageInput() {
        TextArea({
            text: $$this.inputMessage,
            placeholder: $r('app.string.placeholder'),
            controller: this.textAreaController
        }).layoutWeight(1)
    }

    @Builder
    SendButton() {
        Button($r('app.string.button_send'))
            .enabled(this.inputMessage.trim() != '')
            .backgroundColor(getColorGroup(this.themeColor).main)
            .onClick(() => {
                const messageWillSend = this.inputMessage.trim()
                this.nextSizeChangeNeedScrollToBottom!.value = true
                this.messageDataList.push(new MessageData({
                    role: 'user',
                    content: messageWillSend,
                    inRequest: true,
                }))
            })
    }
}