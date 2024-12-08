import { BSColor, BSColorNameMap, getColorGroup } from '@iuroc/bootstrap5-color'
import { relationalStore } from '@kit.ArkData'
import { ChatData } from '../utils/db'
import { CustomContentDialog } from '@kit.ArkUI'

@CustomDialog
export struct RenameDialog {
    controller: CustomDialogController
    @Consume renameDialogChatDataIndex: number
    @Consume rdbStore: relationalStore.RdbStore
    @Consume chatDataList: ChatData[]
    @State text: string = ''
    @Consume defaultChatTitle: string
    @Consume themeColor: BSColorNameMap

    aboutToAppear(): void {
        this.text = this.chatDataList[this.renameDialogChatDataIndex].title
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
                    fontColor: BSColor.white,
                    action: () => {
                        this.updateChatTitle()
                        this.controller.close()
                    },
                },
            ]
        })
    }

    updateChatTitle() {
        this.chatDataList[this.renameDialogChatDataIndex].title = this.text || this.defaultChatTitle
        const predicates = new relationalStore.RdbPredicates('chat')
        predicates.equalTo('id', this.chatDataList[this.renameDialogChatDataIndex].id)
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
