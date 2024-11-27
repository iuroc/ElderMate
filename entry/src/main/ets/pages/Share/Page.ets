@Component
export struct Page {
    @Consume pathInfos: NavPathStack

    build() {
        NavDestination() {
            Button('分享生活').onClick(() => {
                console.log('iuroc', this.pathInfos.getAllPathName())
            })
        }
        .title('分享生活')
    }
}