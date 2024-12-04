import { BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { BSColor } from '@iuroc/bootstrap5-color/Index'
import { window } from '@kit.ArkUI'
import { selectPanelMenuElements } from '../config/selectPanelMenuElements'
import { BooleanValue, isAllSelected, selectedItems, } from '../utils/utils'
import { MessageData } from './MessageListItem'

@Component
export struct BottomPanel {
    @Link inputMessage: string
    @State paddingBottom: number = 0
    @Consume messageDataList: MessageData[]
    @Consume themeColor: BSColorNameMap
    @Consume pathInfos: NavPathStack
    @Consume isSelectMode: boolean
    @Require messageListScroller = new Scroller()
    @Require nextSizeChangeNeedScrollToBottom = new BooleanValue(false)
    @Require textAreaController = new TextAreaController()

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
                // 消息发送按钮
                this.SendButton()
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
        Button((isAllSelected(this.messageDataList) ? '全不选' : '全选')).onClick(() => {
            const newSelectedStatus = !isAllSelected(this.messageDataList)
            this.messageDataList.forEach(item => item.selected = newSelectedStatus)
        })
            .backgroundColor(
                isAllSelected(this.messageDataList) ? BSColor.warning_bg_subtle : BSColor.success_bg_subtle
            )
            .fontColor(
                isAllSelected(this.messageDataList) ? BSColor.warning_text_emphasis : BSColor.success_text_emphasis
            )
        Button('退出多选', { buttonStyle: ButtonStyleMode.NORMAL })
            .fontColor(getColorGroup(this.themeColor).main)
            .onClick(() => {
                this.quitSelectMode()
            })
        Button('选中项操作')
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
            controller: this.textAreaController,
        }).layoutWeight(1)
    }

    /** 消息发送按钮 */
    @Builder
    SendButton() {
        Button($r('app.string.button_send'))
            .enabled(this.inputMessage.trim() != '')
            .backgroundColor(getColorGroup(this.themeColor).main)
            .onClick(() => {
                const messageWillSend = this.inputMessage.trim()
                this.inputMessage = ''
                this.nextSizeChangeNeedScrollToBottom.value = true
                this.messageDataList.push(new MessageData({
                    role: 'user',
                    content: messageWillSend,
                    inRequest: true,
                }))
            })
            .alignSelf(ItemAlign.End)
    }
}