import { BSColor } from "@iuroc/bootstrap5-color"
import { getUserInfo } from "../Login/util"
import { clearUserData } from "./utils"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        NavDestination() {
            Column({ space: 20 }) {
                Text(JSON.stringify(getUserInfo()))
                Button('退出登录').backgroundColor(BSColor.danger)
                    .onClick(() => {
                        clearUserData().then(() => {
                            this.pathInfos.pushPath({ name: 'Login' }, false)
                        })
                    })
            }.padding(20)
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}