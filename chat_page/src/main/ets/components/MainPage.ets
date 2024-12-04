import { BSColorNameMap } from '@iuroc/bootstrap5-color'
import { exampleMessageDataList } from '../config/exampleMessageDataList'
import { BottomPanel } from './BottomPanel'
import { defaultMessageDataList } from '../config/defaultMessageDataList'
import { MessageList } from './MessageList'
import { MessageData } from './MessageListItem'
import { BooleanValue } from '../utils/utils'

@Component
export struct MainPage {
    @State navTitle: string = ''
    @State inputMessage: string = ''
    @Provide messageDataList: MessageData[] = []
    @Provide themeColor: BSColorNameMap = 'danger'
    @Provide isSelectMode: boolean = false
    /** 页面是否被触摸，从第一次触摸开始，该值由 `false` 变为 `true` */
    pageHasTouch = new BooleanValue()
    messageListScroller = new Scroller()
    /** 下一次的消息列表内容的尺寸变化后，是否需要滚动到列表底部
     *
     * 如果需要在列表高度更新后自动滚动到底部，则需要在更新高度前将该值设置为 `true`，在自动滚动底部完成后将自动变回 `false`
     */
    nextSizeChangeNeedScrollToBottom = new BooleanValue()
    textAreaController = new TextAreaController()

    async aboutToAppear() {
        this.navTitle = await getContext().resourceManager.getStringValue($r('app.string.chat_assistant'))

        this.messageDataList = defaultMessageDataList.concat(exampleMessageDataList)
    }

    build() {
        NavDestination() {
            MessageList({
                messageListScroller: this.messageListScroller,
                nextSizeChangeNeedScrollToBottom: this.nextSizeChangeNeedScrollToBottom,
                textAreaController: this.textAreaController,
                pageHasTouch: this.pageHasTouch
            }).layoutWeight(1)
            BottomPanel({
                messageListScroller: this.messageListScroller,
                inputMessage: this.inputMessage,
                textAreaController: this.textAreaController,
                nextSizeChangeNeedScrollToBottom: this.nextSizeChangeNeedScrollToBottom
            })
        }
        .title(this.navTitle)
        .onTouch(() => {
            this.pageHasTouch.value = true
        })
    }
}

