import { call, observer } from '@kit.TelephonyKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { ComposeListItem, IconType, LengthMetrics } from '@kit.ArkUI'

@Component
export struct Home {
    async aboutToAppear() {

    }

    build() {
        RelativeContainer() {
            Scroll() {
                Column() {
                    List() {
                        ListItem() {
                            ComposeListItem({
                                contentItem: {
                                    iconStyle: IconType.HEAD_SCULPTURE,
                                    icon: $r("app.media.person_shield_fill"),
                                    primaryText: '紧急求助',
                                    secondaryText: '给您的紧急联系人打电话'
                                }
                            })
                        }

                        ListItem() {
                            ComposeListItem({
                                contentItem: {
                                    iconStyle: IconType.HEAD_SCULPTURE,
                                    icon: $r("app.media.doc_plaintext_and_pencil"),
                                    primaryText: '用药提醒',
                                    secondaryText: '提醒您今天的用药安排'
                                }
                            })
                        }

                        ListItem() {
                            ComposeListItem({
                                contentItem: {
                                    iconStyle: IconType.HEAD_SCULPTURE,
                                    icon: $r("app.media.doc_plaintext_and_pencil"),
                                    primaryText: '用药提醒',
                                    secondaryText: '提醒您今天的用药安排'
                                }
                            })
                        }
                    }
                }
            }
            .padding(15)
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
        }
    }
}