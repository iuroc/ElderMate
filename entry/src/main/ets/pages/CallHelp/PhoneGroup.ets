import { BSColor } from '@iuroc/bootstrap5-color'
import { ComposeListItem, IconType, promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { call } from '@kit.TelephonyKit'

@Builder
export function PhoneGroup(config: PhoneGroupConfig, isPerson = false, addDialogController?: CustomDialogController) {
    Column({ space: 5 }) {
        Text(config.header).fontSize(14).fontColor(BSColor.secondary).width('100%').padding({
            left: 15,
            right: 15,
            top: 15,
        })
        ForEach(config.phones, (phone: PhoneConfig) => {
            ComposeListItem({
                contentItem: {
                    primaryText: phone.primaryText,
                    secondaryText: phone.secondaryText,
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: phone.icon
                },
                operateItem: {
                    icon: {
                        value: $r('sys.media.ohos_ic_public_phone'),
                        action: () => {
                            makeCallWithToast(phone.callNum)
                        }
                    }
                }
            }).onClick(() => {
                makeCallWithToast(phone.callNum)
            })
        })
        if (isPerson) {
            Button('新增紧急联系人').margin({ bottom: 10 }).buttonStyle(ButtonStyleMode.TEXTUAL)
                .onClick(() => {
                    addDialogController?.open()
                })
        }
    }
    .padding({ bottom: 4 })
    .backgroundColor(BSColor.light)
    .borderRadius(15)
}

function makeCallWithToast(num: string) {
    if (canIUse('SystemCapability.Applications.Contacts')) {
        call.makeCall(num.toString()).catch((error: BusinessError) => {
            promptAction.showToast({ message: error.message })
        })
    } else {
        promptAction.showToast({ message: '当前设备不支持该功能' })
    }
}


@ObservedV2
export class PhoneGroupConfig {
    @Trace header: string
    @Trace phones: PhoneConfig[]

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


