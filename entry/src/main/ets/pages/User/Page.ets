@Component
export struct Page {
    @Consume pathInfos: NavPathStack

    build() {
        NavDestination() {
            Button('个人中心').onClick(() => {
                console.log('iuroc', this.pathInfos.getAllPathName())
            })
        }
        .title('个人中心')
    }
}