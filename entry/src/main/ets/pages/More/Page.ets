import { webview } from '@kit.ArkWeb'
import { ComposeListItem, IconType } from '@ohos.arkui.advanced.ComposeListItem'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            List() {
                ForEach(this.links(), (link: ShareLink, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: link.title,
                                iconStyle: IconType.SYSTEM_ICON,
                                icon: link.icon || $r('sys.media.ic_public_worldclock_filled')
                            }
                        }).onClick(() => {
                            this.pathInfos.pushPath({ name: 'WebView', param: link })
                        })
                    }
                    .padding({ left: 10, right: 10 })
                })
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
    }

    links(): ShareLink[] {
        return [
            {
                title: '网址导航',
                href: 'https://dhfs.heytapimage.com/userfiles/cms/navi/index_1.html',
            },
            {
                title: '天气预报',
                href: 'https://xw.tianqi.qq.com/'
            },
            {
                title: '微博热搜',
                href: 'https://m.weibo.cn/p/index?containerid=106003type%3D25%26t%3D3%26disable_hot%3D1%26filter_type%3Drealtimehot'
            },
            {
                title: '热门短剧',
                href: 'https://vt.quark.cn/blm/hot-board-599/tab?app=short'
            },
            {
                title: '央视网',
                href: 'https://m.cctv.com/',
                icon: $r('app.media.link_cctv')
            },
            {
                title: '央广网',
                href: 'https://m.cnr.cn/',
                icon: $r('app.media.link_ygw')
            },
            {
                title: '腾讯网',
                href: 'https://news.qq.com/',
                icon: $r('app.media.link_txw')
            }
        ]
    }
}

export interface ShareLink {
    title: string
    href: string
    description?: string
    icon?: ResourceStr
}

@Builder
export function PageBuilder() {
    Page()
}