import { BSColor } from '@iuroc/bootstrap5-color'
import { CustomContentDialog, promptAction } from '@kit.ArkUI'
import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

@CustomDialog
export struct AddPersonCall {
    controller: CustomDialogController
    @Require createPersonCall: (name: string, callNum: string) => void = Object()
    @State name: string = ''
    @State phoneNum: string = ''

    build() {
        CustomContentDialog({
            primaryTitle: '新增紧急联系人',
            buttons: [
                {
                    value: '取消',
                    fontColor: BSColor.secondary,
                    action: () => {
                        this.controller.close()
                    }
                },
                {
                    value: '确定',
                    action: () => {
                        try {
                            this.createPersonCall(this.name, this.phoneNum)
                            this.controller.close()
                        } catch (error) {
                            promptAction.showToast(error)
                        }
                    }
                },
            ]
        }) {
            Column({ space: 10 }) {
                TextInput({ placeholder: '请输入姓名', text: $$this.name }).defaultFocus(true)
                TextInput({ placeholder: '请输入手机号码', text: $$this.phoneNum })
            }
        }
    }
}