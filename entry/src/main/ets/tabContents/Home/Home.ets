import { HomeList } from './HomeList'

@Component
export struct Home {
    @Require tabsController: TabsController = new TabsController()

    async aboutToAppear() {

    }

    build() {
        RelativeContainer() {
            Scroll() {
                Column() {
                    HomeList({ tabsController: this.tabsController })
                    HomeList({ tabsController: this.tabsController })
                }
            }
        }
    }
}