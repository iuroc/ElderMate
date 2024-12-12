import { BSColor, getColorGroup } from "@iuroc/bootstrap5-color"
import { window } from "@kit.ArkUI"
import { Chat } from "../common/Chat"
import { Message } from "../common/Message"
import { BSColorGroup } from "../common/types"

@ComponentV2
export struct BottomPanel {
    @Local paddingBottom: number = 0
    /** 消息输入框的内容 */
    @Param @Require inputValue: string
    @Param @Require messages: Message[]
    @Param @Require chats: Chat[]
    @Param @Require themeColor: BSColorGroup = Object()
    @Param @Require isSelectMode: boolean
    @Event $inputValue: (value: string) => void
    @Event $themeColor: (value: BSColorGroup) => void

    build() {
        Row({ space: 10 }) {
            this.MessageInput()
            this.SendButton()
        }
        .width('100%')
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

    aboutToAppear(): void {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.on('keyboardHeightChange', height => {
                this.paddingBottom = height > 0 ? 10 : 0
            })
        })
    }

    @Builder
    MessageInput() {
        TextArea({ text: this.inputValue, placeholder: '您可以问我任何问题' })
            .layoutWeight(1)
            .onChange(value => this.$inputValue(value))
    }

    @Builder
    SendButton() {
        Button('发送')
            .backgroundColor(this.themeColor.main)
            .onClick(() => {
                this.$themeColor(getColorGroup('danger'))
            })
    }

    @Builder
    CancelButton() {

    }
}