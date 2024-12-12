import { Message } from '../common/Message'
import { MessageListItem } from './MessageListItem'

@ComponentV2
export struct MessageList {
    @Param @Require messages: Message[]
    @Consumer() autoScrollBottom: boolean = false
    @Param @Once @Require scroller: Scroller

    build() {
        Scroll(this.scroller) {
            Column({ space: 15 }) {
                ForEach(this.messages, (message: Message, index) => {
                    ListItem() {
                        MessageListItem({
                            message,
                            messages: this.messages,
                            index
                        })
                    }
                })
            }
            .onSizeChange((_oldValue, newValue) => {
                if (newValue.height && newValue.height > 0) {
                    // 切换多选模式的瞬间，列表高度会发生变化
                    // 所以需要在切换多选模式之前，将 autoScrollBottom 更新为 false
                    if (this.autoScrollBottom) {
                        this.scroller.scrollEdge(Edge.Bottom)
                    }
                }
            })
        }
        .padding(15)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.getUIContext().getFocusController().clearFocus()
            }
        })
    }
}