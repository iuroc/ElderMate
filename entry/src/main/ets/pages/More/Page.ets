import { webview } from '@kit.ArkWeb'

@Component
struct Page {
    controller = new webview.WebviewController()

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            Web({
                src: 'https://appgallery.huawei.com/app/detail?id=com.easy.hmos.abroad',
                controller: this.controller
            })
                .width('100%')
                .height('100%')
                .onAppear(() => {
                    this.controller.enableSafeBrowsing(false)
                })
                .domStorageAccess(true)
        }.hideTitleBar(true)
    }
}

@Builder
export function PageBuilder() {
    Page()
}