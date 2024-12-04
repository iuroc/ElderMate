import { MessageData } from './util'
import { pasteboard } from '@kit.BasicServicesKit'
import { MessageItem } from './MessageItem'

/**
 * 消息列表容器
 */
@Component
export struct MessageList {
    scroller = new Scroller()
    /** 消息输入框控制器 */
    @Require textAreaController = new TextAreaController()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Consume messageDataList: MessageData[]
    /** Scroll 是否已经执行过 onSizeChange 回调
     *
     * 用于初始进入页面自动滚动到消息列表底部 */
    hasInitSizeChange: boolean = false

    build() {
        Scroll(this.scroller) {
            Column({ space: 20 }) {
                ForEach(this.messageDataList, (item: MessageData) => {
                    MessageItem({ data: item })
                })
            }
            .margin(20)
        }
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.textAreaController.stopEditing()
            }
        })
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .onSizeChange(event => {
            if (this.hasInitSizeChange) {
                // 判断之前已经执行过了，不再执行
                return
            }
            if (event.height && event.height > 0) {
                // 判断键盘完全拉起，执行滚动到列表底部
                this.hasInitSizeChange = true
                this.scroller.scrollEdge(Edge.Bottom)
            }
        })
    }
}