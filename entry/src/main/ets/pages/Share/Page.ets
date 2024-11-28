@Component
export struct Page {
    @Consume pathInfos: NavPathStack

    build() {
        NavDestination() {
            Button('聊天助手').onClick(() => {
                console.log('iuroc', this.pathInfos.getAllPathName())
            })
        }
        .title('聊天助手')
    }
}