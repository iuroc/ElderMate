import { ChatData, deleteChatById, deleteMessagesByChatId, } from "../utils/db"
import { ComposeListItem, CustomContentDialog, IconType } from "@kit.ArkUI"
import { getDatetimeString } from "../utils/utils"
import { MessageData } from "./MessageListItem"
import { ChatModel } from "@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat"
import { relationalStore } from "@kit.ArkData"
import { BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"

@CustomDialog
export struct ChatListDialog {
    controller: CustomDialogController = new CustomDialogController({
        builder: ChatListDialog({ showChat: Object(), unshiftNewChatToList: Object() }),
    })
    @Consume chatDataList: ChatData[]
    @Consume currentChatId: number
    @Consume messageDataList: MessageData[]
    @Consume navTitle: string
    @Consume openaiModel: ChatModel
    @Consume rdbStore: relationalStore.RdbStore
    @Consume themeColor: BSColorNameMap
    @Consume defaultOpenaiModel: ChatModel
    @Require showChat: (chatData: ChatData) => void = Object()
    @Require unshiftNewChatToList: () => void = Object()

    build() {
        CustomContentDialog({
            primaryTitle: '历史对话',
            contentBuilder: () => {
                this.Content()
            },
            buttons: [
                {
                    value: '取消',
                    action: () => {
                        this.controller.close()
                    }
                }
            ],
            contentAreaPadding: { left: 10, right: 10 }
        })
    }

    @Builder
    Content() {
        List() {
            ForEach(this.chatDataList, (chatData: ChatData, index) => {
                ListItem() {
                    ComposeListItem({
                        contentItem: {
                            primaryText: chatData.title,
                            secondaryText: getDatetimeString(chatData.createTime),
                            iconStyle: IconType.SYSTEM_ICON,
                            icon: $r('sys.media.ohos_ic_public_clock'),
                        },
                        operateItem: {
                            icon: {
                                value: $r('app.media.trash'),
                                action: () => {
                                    // 删除当前 chat_id 的 message 记录
                                    deleteMessagesByChatId(this.rdbStore, chatData.id)
                                    // 删除当前 chat_id 的 chat 记录
                                    deleteChatById(this.rdbStore, chatData.id)
                                    // 删除当前 index 的数组元素
                                    this.chatDataList.splice(index, 1)
                                    // 判断是否将唯一的数组元素删除了
                                    if (this.chatDataList.length == 0) {
                                        // 全部 chat 都被删除了，创建新的 chat
                                        this.unshiftNewChatToList()
                                        this.showChat(this.chatDataList[0])
                                        this.controller.close()
                                    } else if (this.currentChatId == chatData.id) {
                                        // 此次删除的是 currentChatId，那么重新显示最新的 chat
                                        this.showChat(this.chatDataList[0])
                                    }
                                }
                            }
                        }
                    })
                        .backgroundColor(
                            this.currentChatId == chatData.id
                                ? getColorGroup(this.themeColor).background :
                                undefined
                        )
                        .borderRadius(10)
                        .onClick(() => {
                            if (this.currentChatId == chatData.id) {
                                // 当前页面显示的 chat 就是点击的这个 chat，所以不进行加载
                                this.controller.close()
                                return
                            }
                            this.showChat(chatData)
                            this.controller.close()
                        })
                }
            })
        }
        .width('100%')
        .height('70%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}