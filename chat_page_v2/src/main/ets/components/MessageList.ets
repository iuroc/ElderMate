import { BSColor, getColorGroup } from '@iuroc/bootstrap5-color'
import { Chat } from '../common/Chat'
import { Message } from '../common/Message'
import { BSColorGroup } from '../common/types'
import { LengthMetrics } from '@kit.ArkUI'
import { MessageListItem } from './MessageListItem'

@ComponentV2
export struct MessageList {
    @Param @Require messages: Message[]
    @Param @Require chats: Chat[]
    @Param @Require themeColor: BSColorGroup = Object()
    @Param @Require isSelectMode: boolean

    build() {
        Scroll() {
            Column({ space: 15 }) {
                ForEach(this.messages, (message: Message, index) => {
                    ListItem() {
                        MessageListItem({
                            message: message,
                            isSelectMode: this.isSelectMode,
                            themeColor: this.themeColor
                        })
                    }
                })
            }
        }
        .padding(15)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}