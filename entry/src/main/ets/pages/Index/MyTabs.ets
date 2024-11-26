import { Home as HomeTabContent } from '../../tabContents/Home/Home'
import { Community as CommunityTabContent } from '../../tabContents/Community/Community'
import { Assistant as AssistantTabContent } from '../../tabContents/Assistant/Assistant'
import { News as NewsTabContent } from '../../tabContents/News/News'
import { Profile as ProfileTabContent } from '../../tabContents/Profile/Profile'
import { getNavigationConfig, NavigationConfig } from './MyNavigation'

@Component
export struct MyTabs {
    @Link navigationMenuItems: NavigationMenuItem[]
    @Link navigationTitleMode: NavigationTitleMode
    @Link navigationTitle: string
    /** 每个页面单独的导航配置 */
    @Require navigationConfig: NavigationConfig = getNavigationConfig()
    /** 设置默认显示的页面 */
    private defaultTabsIndex = TabsIndex.Home
    private tabsController = new TabsController()

    aboutToAppear(): void {
        // 设置初始状态下
        const config = this.navigationConfig[tabsNameMap[this.defaultTabsIndex]]
        this.navigationMenuItems = config.menuItems
        this.navigationTitleMode = config.titleMode
        this.navigationTitle = config.title
    }

    build() {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.defaultTabsIndex }) {
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
        .onAnimationStart((_, targetIndex: TabsIndex) => {
            handleAnimationStart(this, targetIndex)
        })
    }
}

/** 监听每次切换 `Tabs` 导航页面，比 `onChange` 更早 */
const handleAnimationStart = (that: MyTabs, targetIndex: TabsIndex) => {
    const currentNavigationConfig = that.navigationConfig[tabsNameMap[targetIndex]]
    that.navigationTitleMode = currentNavigationConfig.titleMode
    that.navigationTitle = currentNavigationConfig.title
    that.navigationMenuItems = currentNavigationConfig.menuItems

    switch (targetIndex) {
        case TabsIndex.Home:
            break
        case TabsIndex.Community:
            break
        case TabsIndex.Assistant:
            break
        case TabsIndex.News:
            break
        case TabsIndex.Profile:
            break
    }
}

/** 底部导航栏每个页面对应的下标 */
export enum TabsIndex {
    /** 首页 */
    Home,
    /** 社区 */
    Community,
    /** 助手 */
    Assistant,
    /** 资讯 */
    News,
    /** 我的 */
    Profile
}

/** 页面标识列表 */
export type TabsNameMap = 'home' | 'community' | 'assistant' | 'news' | 'profile'

const tabsNameMap: Record<TabsIndex, TabsNameMap> = ['home', 'community', 'assistant', 'news', 'profile']
