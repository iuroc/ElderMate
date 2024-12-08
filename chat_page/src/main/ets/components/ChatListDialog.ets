import { ChatData, deleteChatById, deleteMessagesByChatId, } from "../utils/db"
import { ComposeListItem, CustomContentDialog, IconType } from "@kit.ArkUI"
import { getDatetimeString } from "../utils/utils"
import { MessageData } from "./MessageListItem"
import { relationalStore } from "@kit.ArkData"
import { BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"

@CustomDialog
struct RenameDialog {
    controller: CustomDialogController
    @Link chatDataIndex: number
    @Consume rdbStore: relationalStore.RdbStore
    @Consume chatDataList: ChatData[]
    @State text: string = ''
    @Consume defaultChatTitle: string
    @Consume themeColor: BSColorNameMap

    aboutToAppear(): void {
        this.text = this.chatDataList[this.chatDataIndex].title
    }

    build() {
        CustomContentDialog({
            primaryTitle: '重命名对话',
            contentBuilder: () => {
                this.Body()
            },
            buttons: [
                {
                    value: '取消',
                    fontColor: getColorGroup(this.themeColor).main,
                    action: () => {
                        this.controller.close()
                    }
                },
                {
                    value: '确定',
                    background: getColorGroup(this.themeColor).main,
                    action: () => {
                        this.updateChatTitle()
                        this.controller.close()
                    },
                    buttonStyle: ButtonStyleMode.EMPHASIZED
                },
            ]
        })
    }

    updateChatTitle() {
        this.chatDataList[this.chatDataIndex].title = this.text || this.defaultChatTitle
        const predicates = new relationalStore.RdbPredicates('chat')
        predicates.equalTo('id', this.chatDataList[this.chatDataIndex].id)
        this.rdbStore.updateSync({ title: this.text }, predicates)
    }

    @Builder
    Body() {
        Column() {
            TextInput({ text: $$this.text, placeholder: '请输入新的标题' })
                .defaultFocus(true)
        }
    }
}

@CustomDialog
export struct ChatListDialog {
    controller: CustomDialogController
    @State renameDialogChatDataIndex: number = 0
    renameDialogController = new CustomDialogController({
        builder: RenameDialog({
            chatDataIndex: this.renameDialogChatDataIndex
        }),
        showInSubWindow: true,
    })
    @Consume chatDataList: ChatData[]
    @Consume currentChatIndex: number
    @Consume messageDataList: MessageData[]
    @Consume rdbStore: relationalStore.RdbStore
    @Consume themeColor: BSColorNameMap
    @Require showChat: (index: number) => void = Object()
    @Require unshiftNewChatToList: () => void = Object()
    @Consume autoScrollToBottom: boolean

    build() {
        CustomContentDialog({
            primaryTitle: '历史对话',
            contentBuilder: () => {
                this.Content()
            },
            buttons: [
                {
                    value: '取消',
                    background: getColorGroup(this.themeColor).background,
                    fontColor: getColorGroup(this.themeColor).font,
                    action: () => {
                        this.controller.close()
                    }
                }
            ],
            contentAreaPadding: { left: 0, right: 0 }
        })
    }

    @Builder
    Content() {
        List({ initialIndex: this.currentChatIndex }) {
            ForEach(this.chatDataList, (chatData: ChatData, index) => {
                ListItem() {
                    ComposeListItem({
                        contentItem: {
                            primaryText: chatData.title,
                            secondaryText: getDatetimeString(chatData.createTime),
                            iconStyle: IconType.SYSTEM_ICON,
                            icon: $r('app.media.ellipsis_message'),
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
                                        this.showChat(0)
                                        this.controller.close()
                                    } else if (this.currentChatIndex == index) {
                                        // 此次删除的是 currentChatId，那么重新显示最新的 chat
                                        this.showChat(0)
                                    }
                                }
                            },
                            subIcon: {
                                value: $r('app.media.rename'),
                                action: () => {
                                    this.renameDialogChatDataIndex = index
                                    this.renameDialogController.open()
                                }
                            }
                        }
                    })
                        .onClick(() => {
                            this.autoScrollToBottom = true
                            if (this.currentChatIndex == index) {
                                // 当前页面显示的 chat 就是点击的这个 chat，所以不进行加载
                                this.controller.close()
                                return
                            }
                            this.showChat(index)
                            this.controller.close()
                        })
                }
                .borderRadius(16)
                .padding({
                    top: this.currentChatIndex == index ? 4 : 0,
                    bottom: this.currentChatIndex == index ? 4 : 0
                })
                .margin({ bottom: index == this.chatDataList.length - 1 ? 10 : 0 })
                .backgroundColor(this.currentChatIndex == index ? getColorGroup(this.themeColor).background :
                    undefined)
            })
        }
        .width('100%')
        .height('70%')
        .padding({ left: 10, right: 10 })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }

    // getChatIndex(chatId: number) {
    //     return this.chatDataList.findIndex(i => i.id == chatId)
    // }
}