import { User } from "../Login/utils"
import { deleteUser, getUsers, UserInResponse } from "./utils"
import { ComposeListItem, IconType } from "@ohos.arkui.advanced.ComposeListItem"
import { BSColor } from "@iuroc/bootstrap5-color"

@Entry
struct Page {
    @State users: UserInResponse[] = []

    aboutToAppear(): void {
        getUsers().then(result => {
            this.users.push(...result)
        })
    }

    build() {
        NavDestination() {
            List() {
                ForEach(this.users, (user: UserInResponse, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                iconStyle: IconType.HEAD_SCULPTURE,
                                icon: $r('app.media.person_2'),
                                primaryText: user.phone,
                                secondaryText: `注册时间：${new Date(user.createTime).toLocaleString()}`,
                                description: `${user.role == 'admin' ? '管理员' : '普通用户'}`
                            },
                        })
                    }
                    .gesture(LongPressGesture().onAction(() => {
                        AlertDialog.show({
                            title: '删除用户',
                            message: '是否要删除该用户？',
                            buttons: [
                                {
                                    value: '确定',
                                    action: () => {
                                        deleteUser(user.id).then(() => {
                                            this.users.splice(index, 1)
                                        })
                                    },
                                    fontColor: BSColor.danger
                                },
                                {
                                    value: '取消',
                                    action: () => {

                                    }
                                }
                            ]
                        })
                    }))
                })
            }
            .width('100%')
            .height('100%')
        }
        .title('用户管理')
    }
}

@Builder
export function PageBuilder() {
    Page()
}