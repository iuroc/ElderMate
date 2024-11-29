import { ComposeListItem, ContentItem, IconType, OperateItem } from '@kit.ArkUI'

/** 导航页内容 */
@Component
export struct NavigationContent {
    scroller?: Scroller

    build() {
        HomeList({ scroller: this.scroller })
    }
}

interface ListItem {
    contentItem: ContentItem
    operateItem?: OperateItem
    onClick: (event: ClickEvent) => void
}

@Component
struct HomeList {
    scroller = new Scroller()
    private listItems = this.makeListItems()
    @Consume('pathInfos') pathInfos: NavPathStack

    build() {
        List({ scroller: this.scroller }) {
            ForEach(this.listItems, (item: ListItem) => {
                ListItem() {
                    ComposeListItem({
                        contentItem: item.contentItem,
                        operateItem: item.operateItem,
                    }).onClick(item.onClick)
                }
            })
        }
        .width('auto')
        .height('auto')
        .padding(10)
    }

    private makeListItems(): ListItem[] {
        const that = this
        return [
            {
                contentItem: {
                    primaryText: '用药提醒',
                    secondaryText: '查看今天需要吃的药',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.calendar_badge_clock'),
                },
                onClick() {
                }
            },
            {
                contentItem: {
                    primaryText: '紧急求助',
                    secondaryText: '拨打紧急求助电话',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.person_shield_fill')
                },
                onClick() {
                }
            },
            {
                contentItem: {
                    primaryText: '我的医疗记录',
                    secondaryText: '给医生看我的就诊记录',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.doc_text_badge_checkmark')
                },
                onClick() {
                }
            },
            {
                contentItem: {
                    primaryText: '我的个人信息',
                    secondaryText: '展示我的个人信息给他人',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.info_shield')
                },
                onClick() {
                }
            },
            {
                contentItem: {
                    primaryText: '天气预报',
                    secondaryText: '轻松查看今天的天气',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.icloud')
                },
                onClick() {
                }
            },
            {
                contentItem: {
                    primaryText: '智能聊天助手',
                    secondaryText: '随时陪您聊天和解答问题',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.ellipsis_bubble')
                },
                onClick() {
                    that.pathInfos.pushPath({ name: 'Chat' })
                }
            },
            {
                contentItem: {
                    primaryText: '社区活动',
                    secondaryText: '参加或投稿社区活动',
                    iconStyle: IconType.HEAD_SCULPTURE,
                    icon: $r('app.media.flag')
                },
                onClick() {

                }
            },
        ]
    }
}