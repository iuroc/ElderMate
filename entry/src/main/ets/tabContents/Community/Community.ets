@Component
export struct Community {
    build() {
        RelativeContainer() {
            Tabs() {
                TabContent() {
                    RelativeContainer() {

                    }
                    .backgroundColor(Color.Pink)
                }.tabBar('生活圈子')

                TabContent() {
                    RelativeContainer() {

                    }
                    .backgroundColor(Color.Yellow)
                }.tabBar('活动中心')
            }
        }
    }
}