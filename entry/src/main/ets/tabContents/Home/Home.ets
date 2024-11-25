import { HomeList } from './HomeList'

@Component
export struct Home {
    /** 入口页面的底部导航栏控制器 */
    @Require tabsController: TabsController = new TabsController()

    async aboutToAppear() {

    }

    build() {
        RelativeContainer() {
            Scroll() {
                Column() {
                    HomeList({ tabsController: this.tabsController })
                }
            }
        }
    }
}