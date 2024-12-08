import { MessageData, MessageListItem } from './MessageListItem'

@Component
export struct MessageList {
    @Consume messageDataList: MessageData[]
    @Require messageListScroller = new Scroller()
    @Consume pageHasTouch: boolean
    @Require textAreaController = new TextAreaController()
    @Consume isSelectMode: boolean
    @Consume autoScrollToBottom: boolean

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
                    if (!this.pageHasTouch) {
                        // 表示当前页面还没有被触摸过，表示是刚进入页面，设置列表滚动到底部
                        this.messageListScroller.scrollEdge(Edge.Bottom)
                    } else if (oldValue?.height && oldValue?.height < newValue.height) {
                        // 在进入多选模式后，手动将该值设置为 false
                        // 设置 autoScrollToBottom 变量的目的是在退出多选模式时，禁用自动滚到到底部
                        if (this.autoScrollToBottom) {
                            this.messageListScroller.scrollEdge(Edge.Bottom)
                        } else if (!this.isSelectMode) {
                            // this.autoScrollToBottom = true
                        }
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
        .onReachEnd(() => {
            this.autoScrollToBottom = true
            // console.log('this.autoScrollToBottom = true')
        })
        .onWillScroll((_xOffset, yOffset, _scrollState, scrollSource) => {
            // 手动滚动离开底部，禁用自动滚动底部
            if (yOffset < -10 && scrollSource != ScrollSource.EDGE_EFFECT) {
                if (this.messageListScroller.currentOffset().yOffset > 0) {
                    // console.log('this.autoScrollToBottom = false', yOffset)
                    this.autoScrollToBottom = false
                }
            }
        })
    }
}