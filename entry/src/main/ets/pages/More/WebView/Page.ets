import { webview } from "@kit.ArkWeb"
import { ShareLink } from "../Page"

@ComponentV2
struct Page {
    controller = new webview.WebviewController()
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local src: string = ''
    @Local title: string = ''

    build() {
        NavDestination() {
            Web({
                controller: this.controller,
                src: this.src
            })
                .onSslErrorEvent(event => {
                    event.handler.handleConfirm()
                })
                .domStorageAccess(true)
        }
        .title(this.title)
        .onWillAppear(() => {
            const params = this.pathInfos.getParamByName('WebView') as object[]
            if (params.length == 0) {
                return AlertDialog.show({ message: '未找到初始参数' })
            }
            const param = params[0] as ShareLink
            this.src = param.href
            this.title = param.title
        })
    }
}

@Builder
export function PageBuilder() {
    Page()
}