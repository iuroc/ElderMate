import { Assistant as AssistantTabContent } from '../tabContents/Assistant/Assistant'
import { Community as CommunityTabContent } from '../tabContents/Community/Community'
import { Home as HomeTabContent } from '../tabContents/Home/Home'
import { News as NewsTabContent } from '../tabContents/News/News'
import { Profile as ProfileTabContent } from '../tabContents/Profile/Profile'

@Entry
@Component
struct Index {
    tabsController: TabsController = new TabsController()

    build() {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
            TabContent() {
                HomeTabContent({
                    tabsController: this.tabsController
                })
            }.tabBar('首页')

            TabContent() {
                CommunityTabContent()
            }.tabBar('社区')

            TabContent() {
                AssistantTabContent()
            }.tabBar('助手')

            TabContent() {
                NewsTabContent()
            }.tabBar('资讯')

            TabContent() {
                ProfileTabContent()
            }.tabBar('我的')
        }
    }
}