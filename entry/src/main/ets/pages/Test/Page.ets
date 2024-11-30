@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    @State menus: MenuElement[] = []
    @State status: boolean = false

    build() {
        NavDestination() {
            Navigation() {
                Column() {
                    Button('点击').bindMenu(this.menus)
                    Text(JSON.stringify(this.status))
                }
                .padding({
                    left: 60,
                    right: 60,
                    top: 30,
                    bottom: 30
                })
                .borderRadius(20)
                .backgroundColor(Color.Pink)
                .onTouch(event => {
                    if (event.type == TouchType.Up) {
                        this.status = !this.status
                    }
                })
            }
            .title('测试页面')
        }
        .hideTitleBar(true)
    }
}