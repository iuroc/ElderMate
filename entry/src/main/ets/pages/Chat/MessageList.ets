import { MessageData } from './util'
import { pasteboard } from '@kit.BasicServicesKit'
import { MessageItem } from './MessageItem'

/**
 * 消息列表容器
 */
@Component
export struct MessageList {
    scroller = new Scroller()
    textAreaController = new TextAreaController()
    systemPasteboard = pasteboard.getSystemPasteboard()
    @Consume('messageDataList') dataList: MessageData[]
    /** 文本选择面板要显示的文本 */
    @Consume textSelectModalText: string
    /** 是否处于多选模式 */
    @Consume isSelectMode: boolean
    @Consume isModalShow: boolean
    /** Scroll 是否已经执行过 onSizeChange 回调 */
    hasInitSizeChange: boolean = false

    build() {
        Scroll(this.scroller) {
            Column({ space: 20 }) {
                ForEach(this.dataList, (item: MessageData) => {
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
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .flexGrow(1)
        .onSizeChange(event => {
            if (this.hasInitSizeChange) {
                return
            }
            if (event.height && event.height > 0) {
                this.hasInitSizeChange = true
                this.scroller.scrollEdge(Edge.Bottom)
            }
        })
    }
}