import { MessageData, MessageListItem } from './MessageListItem'
import { BooleanValue } from '../utils/utils'

@Component
export struct MessageList {
    @Consume messageDataList: MessageData[]
    @Require messageListScroller = new Scroller()
    @Require pageHasTouch = new BooleanValue(false)
    @Require textAreaController = new TextAreaController()

    /** 列表上次的长度，如果最新的长度小于该值，表示发生了删除，就不会滚动到底部，否则会滚动到底部。 */
    // private lastListLength = 0

    build() {
        Scroll(this.messageListScroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (messageData: MessageData) => {
                    MessageListItem({ messageData })
                })
            }
            .width('100%')
            .padding(20)
            .onSizeChange((oldValue, newValue) => {
                if (newValue.height && newValue.height > 0) {
                    if (!this.pageHasTouch.value) {
                        // 表示当前页面还没有被触摸过，表示是刚进入页面，设置列表滚动到底部
                        this.messageListScroller.scrollEdge(Edge.Bottom)
                    } else if (oldValue?.height && oldValue?.height < newValue.height) {
                        this.messageListScroller.scrollEdge(Edge.Bottom)
                    }
                }
            })
        }
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .height('100%')
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.textAreaController.stopEditing()
            }
        })
    }
}