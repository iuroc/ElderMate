import { BSColor, getColorGroup } from '@iuroc/bootstrap5-color'
import { window } from '@kit.ArkUI'
import { Message } from '../common/Message'
import { BSColorGroup } from '../common/types'
import { isAllSelected, selectedItems } from '../common/utils'

@ComponentV2
export struct BottomPanel {
    @Local paddingBottom: number = 0
    /** 消息输入框的内容 */
    @Local inputValue: string = ''
    @Param @Require messages: Message[] = []
    @Consumer() themeColor: BSColorGroup = Object()
    @Consumer() isSelectMode: boolean = false
    @Param @Once @Require messageListScroller: Scroller
    @Consumer() navDestinationShow: boolean = true

    build() {
        Row({ space: 10 }) {
            if (this.isSelectMode) {
                this.SelectPanel()
            } else {
                this.MessageInput()
                this.SendButton()
            }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
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

    keyboardHeightChange = (height: number) => {
        this.paddingBottom = height > 0 ? 10 : 0
        if (height > 0) this.messageListScroller.scrollEdge(Edge.Bottom)
    }

    aboutToAppear(): void {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.on('keyboardHeightChange', this.keyboardHeightChange)
        })
    }

    aboutToDisappear(): void {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.off('keyboardHeightChange', this.keyboardHeightChange)
        })
    }

    @Builder
    MessageInput() {
        TextArea({ text: this.inputValue!!, placeholder: '您可以问我任何问题' })
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

    /** 多选状态下的底部操作面板 */
    @Builder
    SelectPanel() {
        Button((isAllSelected(this.messages) ? $r('app.string.deselect_all') : $r('app.string.select_all')))
            .onClick(() => {
                const newSelectedStatus = !isAllSelected(this.messages)
                this.messages.forEach(item => item.selected = newSelectedStatus)
            })
            .backgroundColor(
                isAllSelected(this.messages) ? BSColor.warning_bg_subtle : BSColor.success_bg_subtle
            )
            .fontColor(
                isAllSelected(this.messages) ? BSColor.warning_text_emphasis : BSColor.success_text_emphasis
            )
        Button($r('app.string.exit_multi_select'), { buttonStyle: ButtonStyleMode.NORMAL })
            .fontColor(this.themeColor.main)
            .onClick(() => {
                this.quitSelectMode()
            })
        Button($r('app.string.selected_item_actions'))
            .backgroundColor(this.themeColor.main)// .bindMenu(selectPanelMenuElements(this))
            .enabled(selectedItems(this.messages).length > 0)
    }

    quitSelectMode() {
        this.isSelectMode = false
        this.messages.forEach(message => message.selected = false)
    }
}