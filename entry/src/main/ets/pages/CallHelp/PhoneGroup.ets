import { BSColor } from '@iuroc/bootstrap5-color'
import { ComposeListItem, IconType, promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { call } from '@kit.TelephonyKit'
import { relationalStore } from '@kit.ArkData'

@ComponentV2
export struct PhoneGroup {
    @Require @Param config: PhoneGroupConfig
    /** 弹窗控制器，用于点击按钮新增联系人 */
    @Param addDialogController: CustomDialogController | null = null
    /** 是紧急联系人，而不是公共紧急号码（如 110、119、120） */
    @Param isPerson: boolean = false
    @Param rdbStore: relationalStore.RdbStore | null = null

    build() {
        Column({ space: 5 }) {
            Text(this.config.header).fontSize(14).fontColor(BSColor.secondary).width('100%').padding({
                left: 15,
                right: 15,
                top: 15,
            })
            ForEach(this.config.phones, (phone: PhoneConfig, index) => {
                ComposeListItem({
                    contentItem: {
                        primaryText: phone.primaryText,
                        secondaryText: phone.secondaryText,
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: phone.icon
                    },
                    operateItem: {
                        icon: {
                            value: this.config.editMode
                                ? $r("app.media.trash_danger")
                                : $r('sys.media.ohos_ic_public_phone'),
                            action: () => {
                                if (this.config.editMode) {
                                    this.deletePersonCall(index, phone.callNum)
                                    if (this.config.phones.length == 0) this.config.editMode = false
                                } else {
                                    makeCallWithToast(phone.callNum)
                                }
                            }
                        },
                    }
                }).onClick(() => {
                    if (!this.config.editMode) makeCallWithToast(phone.callNum)
                })
            })
            if (this.isPerson) {
                Row() {
                    if (!this.config.editMode) {
                        Button('新增紧急联系人').buttonStyle(ButtonStyleMode.TEXTUAL)
                            .onClick(() => {
                                this.addDialogController?.open()
                            })
                    }
                    if (this.config.phones.length > 0) {
                        Button(this.config.editMode ? '退出编辑模式' : '编辑模式')
                            .buttonStyle(ButtonStyleMode.TEXTUAL)
                            .fontColor(BSColor.danger)
                            .onClick(() => {
                                this.config.editMode = !this.config.editMode
                            })
                    }
                }
                .margin({ bottom: 10 })
            }
        }
        .padding({ bottom: 4 })
        .backgroundColor(BSColor.light)
        .borderRadius(15)
    }

    deletePersonCall(index: number, callNum: string) {
        this.config.phones.splice(index, 1)
        const predicates = new relationalStore.RdbPredicates('person_call')
        predicates.equalTo('call_num', callNum)
        this.rdbStore?.deleteSync(predicates)
    }
}

function makeCallWithToast(num: string) {
    const showDialog = (_errorMessage = '') => {
        promptAction.showDialog({
            title: `拨号给 ${num}`,
            message: `即将调用系统拨号应用拨打电话，但设备当前环境不支持拨号功能（如模拟器）。请在真机上重试，真机环境将直接跳转到拨号应用。`,
            buttons: [
                { text: '好的', color: BSColor.primary },
            ]
        })
    }
    if (canIUse('SystemCapability.Applications.Contacts')) {
        call.makeCall(num.toString()).catch((_error: BusinessError) => {
            showDialog()
        })
    } else {
        showDialog()
    }
}

@ObservedV2
export class PhoneGroupConfig {
    @Trace header: string
    @Trace phones: PhoneConfig[]
    @Trace editMode: boolean = false

    constructor(config: IPhoneGroupConfig) {
        this.header = config.header
        this.phones = config.phones
    }
}

interface IPhoneGroupConfig {
    header: string
    phones: PhoneConfig[]
}

@ObservedV2
export class PhoneConfig {
    @Trace callNum: string
    @Trace icon: ResourceStr
    @Trace primaryText: string
    @Trace secondaryText: string

    constructor(config: IPhoneConfig) {
        this.callNum = config.callNum
        this.icon = config.icon
        this.primaryText = config.primaryText
        this.secondaryText = config.secondaryText
    }
}

interface IPhoneConfig {
    callNum: string
    icon: ResourceStr
    primaryText: string
    secondaryText: string
}