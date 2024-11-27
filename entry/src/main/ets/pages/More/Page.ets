@Component
export struct Page {
    @Consume pathInfos: NavPathStack

    build() {
        NavDestination() {
            Button('更多资讯').onClick(() => {
                console.log('iuroc', this.pathInfos.getAllPathName())
            })
        }
        .title('更多资讯')
    }
}