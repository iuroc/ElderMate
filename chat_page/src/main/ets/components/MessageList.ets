import { MessageData, MessageListItem } from './MessageListItem'
import { BooleanValue } from '../utils/utils'

@Component
export struct MessageList {
    @Consume messageDataList: MessageData[]
    messageListScroller?: Scroller
    @Require pageHasTouch?: BooleanValue
    @Require nextSizeChangeNeedScrollToBottom?: BooleanValue
    @Require textAreaController?: TextAreaController

    build() {
        Scroll(this.messageListScroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (messageData: MessageData) => {
                    MessageListItem({ messageData })
                })
            }
            .width('100%')
            .padding(20)
            .onSizeChange((_oldValue, newValue) => {
                if (newValue.height && newValue.height > 0) {
                    if (!this.pageHasTouch?.value) {
                        // 表示当前页面还没有被触摸过，表示是刚进入页面，设置列表滚动到底部
                        this.messageListScroller?.scrollEdge(Edge.Bottom)
                    } else if (this.nextSizeChangeNeedScrollToBottom?.value) {
                        this.nextSizeChangeNeedScrollToBottom!.value = false
                        this.messageListScroller?.scrollEdge(Edge.Bottom)
                    }
                }
            })
        }
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .height('100%')
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.textAreaController?.stopEditing()
            }
        })
    }
}