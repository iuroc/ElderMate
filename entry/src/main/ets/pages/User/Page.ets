import { BSColor } from "@iuroc/bootstrap5-color"
import { getUserInfo } from "../Login/utils"
import { clearUserData } from "./utils"
import { ComposeListItem, IconType } from "@ohos.arkui.advanced.ComposeListItem"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 10 }) {
                    Column() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: '我的个人信息',
                                iconStyle: IconType.SYSTEM_ICON,
                                icon: $r('app.media.info_shield')
                            }
                        }).onClick(() => this.pathInfos.pushPath({ name: 'MyInfo' }))
                        ComposeListItem({
                            contentItem: {
                                primaryText: '我的社交圈子',
                                iconStyle: IconType.SYSTEM_ICON,
                                icon: $r('app.media.person_2')
                            }
                        }).onClick(() => this.pathInfos.pushPath({ name: 'Share' }))
                        ComposeListItem({
                            contentItem: {
                                primaryText: '退出登录',
                                iconStyle: IconType.SYSTEM_ICON,
                                icon: $r('app.media.power')
                            }
                        }).onClick(() => {
                            AlertDialog.show({
                                title: '操作提示',
                                message: '确定要退出登录吗？',
                                buttons: [
                                    {
                                        value: '确定退出',
                                        fontColor: BSColor.danger,
                                        action: () => {
                                            clearUserData().then(() => {
                                                this.pathInfos.pushPath({ name: 'Login' }, false)
                                            })
                                        }
                                    },
                                    {
                                        value: '取消',
                                        action: () => {
                                        }
                                    }
                                ]
                            })
                        })
                    }
                    .padding({
                        left: 10,
                        right: 10
                    })
                }
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .title('个人中心')
    }
}

@Builder
export function PageBuilder() {
    Page()
}