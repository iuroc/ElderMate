import { getColorGroup } from "@iuroc/bootstrap5-color"
import { window } from "@kit.ArkUI"
import { BSColorGroup } from "../common/types"

@ComponentV2
export struct BottomPanel {
    /** 消息输入框的内容 */
    @Consumer() messageInputValue: string = Object()
    @Local paddingBottom: number = 0
    @Consumer() themeColor: BSColorGroup = Object()

    build() {
        Row({ space: 10 }) {
            this.MessageInput()
            this.SendButton()
        }
        .width('100%')
        .padding({
            left: 10,
            right: 10,
            bottom: this.paddingBottom
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
        TextArea({ text: $$this.messageInputValue, placeholder: '您可以问我任何问题' })
            .layoutWeight(1)
    }

    @Builder
    SendButton() {
        Button('发送')
            .backgroundColor(this.themeColor.main)
            .onClick(() => {
                this.themeColor = getColorGroup('danger')
            })
    }

    @Builder
    CancelButton() {

    }
}