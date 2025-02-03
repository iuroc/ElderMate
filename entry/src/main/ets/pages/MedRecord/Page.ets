import { BSColor } from '@iuroc/bootstrap5-color'
import { ComposeListItem, IconType, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { formatDateChinese } from '../../common/utils'
import { AddMedRecordPopResult } from './AddMedRecord/utils'
import { deleteMedRecord, getMedRecordList } from './utils'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local medRecords: MedRecordListItemObservedV2[] = []

    build() {
        NavDestination() {
            List() {
                ForEach(this.medRecords, (medRecord: MedRecordListItemObservedV2, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: medRecord.hospitalName,
                                secondaryText: `就诊日期: ` + formatDateChinese(medRecord.visitDate),
                                iconStyle: IconType.SYSTEM_ICON,
                                icon: $r('app.media.yiyuan')
                            }
                        })
                            .gesture(LongPressGesture().onAction(() => {
                                AlertDialog.show({
                                    title: '删除提示',
                                    message: '确定要删除该记录吗？',
                                    buttons: [
                                        {
                                            value: '确定删除',
                                            fontColor: BSColor.danger,
                                            action: () => {
                                                deleteMedRecord(medRecord.id).then(() => {
                                                    this.medRecords.splice(index, 1)
                                                }).catch((error: Error) => {
                                                    promptAction.showToast(error)
                                                })
                                            }
                                        },
                                        {
                                            value: '取消',
                                            action: () => {

                                            }
                                        }
                                    ]
                                })
                            }))
                            .onClick(() => {
                                this.pathInfos.pushPath({ name: 'ViewMedRecord', param: medRecord.id })
                            })
                    }
                    .padding({ left: 10, right: 10 })
                })
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .title('我的医疗记录')
        .menus([
            {
                value: '添加记录',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
                action: () => {
                    this.pathInfos.pushPath({
                        name: 'AddMedRecord',
                        onPop: info => {
                            const result = info.result as AddMedRecordPopResult
                            const medRecord = new MedRecordListItemObservedV2()
                            medRecord.id = result.result.id
                            console.log(JSON.stringify(result.result))
                            medRecord.visitDate = result.config.visitDate
                            medRecord.hospitalName = result.config.hospitalName
                            medRecord.images = result.config.imageURLs.map(url => new MedRecordImageObservedV2(url))
                            this.medRecords.unshift(medRecord)
                        }
                    })
                }
            }
        ])
        .onWillAppear(() => {
            getMedRecordList(0, 120).then(result => {
                result.forEach(item => {
                    const medRecord = new MedRecordListItemObservedV2()
                    medRecord.id = item.id
                    medRecord.visitDate = new Date(item.visitDate)
                    medRecord.hospitalName = item.hospitalName
                    medRecord.createTime = new Date(item.createTime)
                    medRecord.images = item.images.map(item => new MedRecordImageObservedV2(item.url))
                    this.medRecords.push(medRecord)
                })
            })
                .catch((error: Error) => {
                    promptAction.showToast(error)
                })
        })
    }
}

@ObservedV2
export class MedRecordListItemObservedV2 {
    @Trace
    id: number = 0
    @Trace
    visitDate: Date = new Date()
    @Trace
    hospitalName: string = ''
    @Trace
    images: MedRecordImageObservedV2[] = []
    @Trace
    createTime: Date = new Date()
}

@ObservedV2
class MedRecordImageObservedV2 {
    @Trace
    url: string

    constructor(url: string) {
        this.url = url
    }
}

@Builder
export function PageBuilder() {
    Page()
}