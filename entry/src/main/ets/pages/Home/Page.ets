@Component
export struct Page {
    @Consume pathInfos: NavPathStack

    build() {
        NavDestination() {
            Column() {
            }
        }
        .title('智老同行')
    }
}