import { ComposeListItem, IconType, promptAction, SymbolGlyphModifier, SymbolSpanModifier } from "@kit.ArkUI"
import { AddMedPagePopResult } from "./AddMed/Page"
import { getMedAlertList, MedAlertListItem } from "./utils"

/**
 * MedAlert 用药提醒模块
 */
@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local medAlerts: MedAlertObservedV2[] = []

    build() {
        NavDestination() {
            List() {
                ForEach(this.medAlerts, (medAlert: MedAlertObservedV2, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: medAlert.name,
                                secondaryText: `每日 ${medAlert.useCountPerDay} 次`,
                                description: medAlert.description,
                                icon: $r('app.media.yi_liao'),
                                iconStyle: IconType.SYSTEM_ICON
                            }
                        })
                    }
                })
            }
            .width('100%')
            .height('100%')
            .divider({ strokeWidth: 1 })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .padding({ left: 10, right: 10 })
        }
        .title('用药提醒')
        .menus(this.menuItems())
        .onWillAppear(() => {
            this.refresh()
        })
    }

    menuItems(): NavigationMenuItem[] {
        return [{
            value: '新增吃药',
            symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
            action: () => {
                this.pathInfos.pushPath({
                    name: 'AddMed', onPop: info => {
                        const result = info.result as AddMedPagePopResult
                        const medAlert = new MedAlertObservedV2()
                        medAlert.id = result.result.id
                        medAlert.name = result.config.name
                        medAlert.useCountPerDay = result.config.useCountPerDay
                        medAlert.description = result.config.description
                        medAlert.startDate = result.config.startDate
                        medAlert.endDate = result.config.endDate
                        medAlert.createTime = new Date(result.result.createTime)
                        this.medAlerts.push(medAlert)
                    }
                })
            }
        }]
    }

    refresh() {
        getMedAlertList(new Date(), 0, 120).then(result => {
            this.medAlerts.splice(0)
            this.medAlerts.push(...result.map(item => medAlertListItemToMedAlertObservedV2(item)))
        }).catch((error: Error) => {
            promptAction.showToast(error)
        })
    }
}

function medAlertListItemToMedAlertObservedV2(item: MedAlertListItem): MedAlertObservedV2 {
    const medAlert = new MedAlertObservedV2()
    medAlert.id = item.id
    medAlert.name = item.name
    medAlert.useCountPerDay = item.useCountPerDay
    medAlert.description = item.description
    medAlert.startDate = new Date(item.startDate)
    medAlert.endDate = new Date(item.endDate)
    medAlert.createTime = new Date(item.createTime)
    return medAlert
}

@Builder
export function PageBuilder() {
    Page()
}

@ObservedV2
export class MedAlertObservedV2 {
    @Trace
    id: number = 0
    @Trace
    name: string = ''
    @Trace
    useCountPerDay: number = 0
    @Trace
    description: string = ''
    @Trace
    startDate: Date = new Date()
    @Trace
    endDate: Date = new Date()
    @Trace
    createTime: Date = new Date()
}