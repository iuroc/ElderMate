import { Assistant as AssistantTabContent } from '../tabContents/Assistant'
import { Community as CommunityTabContent } from '../tabContents/Community'
import { Home as HomeTabContent } from '../tabContents/Home'
import { News as NewsTabContent } from '../tabContents/News'
import { Profile as ProfileTabContent } from '../tabContents/Profile'

@Entry
@Component
struct Index {
    @State message: string = 'Hello World'

    build() {
        Tabs({ barPosition: BarPosition.End }) {
            TabContent() {
                HomeTabContent()
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