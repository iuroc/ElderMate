import {
    ChatData,
    createNewChatForPage,
    deleteChatById,
    deleteMessagesByChatId,
    getMessagesByChatID
} from "../utils/db"
import { ComposeListItem, CustomContentDialog, IconType } from "@kit.ArkUI"
import { getDatetimeString } from "../utils/utils"
import { MessageData } from "./MessageListItem"
import { ChatModel } from "@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat/chat"
import { relationalStore } from "@kit.ArkData"
import { BSColor, BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"

@CustomDialog
export struct ChatListDialog {
    controller: CustomDialogController = new CustomDialogController({
        builder: ChatListDialog({}),
    })
    @Consume chatDataList: ChatData[]
    @Consume currentChatId: number
    @Consume messageDataList: MessageData[]
    @Consume navTitle: string
    @Consume openaiModel: ChatModel
    @Consume rdbStore: relationalStore.RdbStore
    @Consume themeColor: BSColorNameMap
    @Consume defaultOpenaiModel: ChatModel

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
            ForEach(this.chatDataList, (chatData: ChatData) => {
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
                                    this.chatDataList.forEach((data, index) => {
                                        if (data.id == chatData.id) {
                                            this.chatDataList.splice(index, 1)
                                            deleteMessagesByChatId(this.rdbStore, data.id)
                                            deleteChatById(this.rdbStore, data.id)

                                            if (this.chatDataList.length == 0) {
                                                // 全部 chat 都被删除了，创建新的 chat
                                                const currentChat = createNewChatForPage(
                                                    this.rdbStore,
                                                    this.chatDataList,
                                                    this.defaultOpenaiModel
                                                )
                                                this.currentChatId = currentChat.id
                                                this.messageDataList = getMessagesByChatID(this.rdbStore, this.currentChatId)
                                                this.navTitle = currentChat.title
                                                // 将当前页面的模型类型更新为数据库中最新 chat 的
                                                this.openaiModel = currentChat.model
                                                this.controller.close()
                                            }
                                        }
                                    })
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
                            this.controller.close()
                            if (this.currentChatId == chatData.id) {
                                return
                            }
                            this.currentChatId = chatData.id
                            this.messageDataList = getMessagesByChatID(this.rdbStore, chatData.id)
                            console.log(this.messageDataList.length.toString())
                            this.navTitle = chatData.title
                            // 将当前页面的模型类型更新为数据库中最新 chat 的
                            this.openaiModel = chatData.model
                        })
                }
            })
        }
        .width('100%')
        .height('70%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}