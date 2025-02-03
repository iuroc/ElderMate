import { promptAction, SymbolGlyphModifier, SymbolSpanModifier } from '@kit.ArkUI'
import { apiOrigin } from '../../../common/config'
import { extname, extToMime, formatDateChinese, getPreviewFileUriForImageURL } from '../../../common/utils'
import { getMedRecordInfo } from './utils'
import { filePreview } from '@kit.PreviewKit'
import { BSColor } from '@iuroc/bootstrap5-color'
import { deleteMedRecord } from '../utils'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local hospitalName: string = ''
    @Local medRecord: string = ''
    @Local images: string[] = []
    @Local visitDate: Date = new Date()
    @Local medRecordId: number = 0
    @Local requestDone: boolean = false

    build() {
        NavDestination() {
            if (this.requestDone)
            Scroll() {
                Column({ space: 15 }) {
                    Row({ space: 10 }) {
                        Text('就诊医院').fontWeight(FontWeight.Bold)
                        Text(this.hospitalName)
                    }
                    .justifyContent(FlexAlign.Start)
                    .width('100%')

                    Row({ space: 10 }) {
                        Text('就诊日期').fontWeight(FontWeight.Bold)
                        Text(formatDateChinese(this.visitDate))
                    }
                    .justifyContent(FlexAlign.Start)
                    .width('100%')

                    if (this.medRecord) {
                        Text('就诊报告').fontWeight(FontWeight.Bold).width('100%')
                        Text(this.medRecord).width('100%').wordBreak(WordBreak.BREAK_WORD)
                    }

                    if (this.images.length > 0) {
                        Text('病历图片').fontWeight(FontWeight.Bold).width('100%')
                        Grid() {
                            ForEach(this.images, (image: string, index) => {
                                GridItem() {
                                    Column() {
                                        Image(apiOrigin + image).borderRadius(10).onClick(async () => {
                                            filePreview.openPreview(getContext(), {
                                                uri: await getPreviewFileUriForImageURL(apiOrigin + image),
                                                title: '查看病历',
                                                mimeType: extToMime(extname(image))[0]
                                            })
                                        })
                                    }
                                }
                            })
                        }
                        .columnsTemplate('1fr 1fr')
                        .columnsGap(10)
                        .rowsGap(10)
                    }
                }
                .padding(15)
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .menus([
            {
                value: '删除',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
                action: () => {
                    AlertDialog.show({
                        title: '删除提示',
                        message: '确定要删除该记录吗？',
                        buttons: [
                            {
                                value: '确定删除',
                                fontColor: BSColor.danger,
                                action: () => {
                                    deleteMedRecord(this.medRecordId).then(() => {
                                        this.pathInfos.pop('delete')
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
                }
            },
            {
                value: '编辑',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')),
                action: () => {

                }
            }
        ])
        .title('查看就诊记录')
        .onWillAppear(() => {
            const params = this.pathInfos.getParamByName('ViewMedRecord') as number[]
            if (params.length > 0 && params[0] != null) {
                const id = params[0] as number
                this.medRecordId = id
                getMedRecordInfo(id).then(info => {
                    this.requestDone = true
                    this.hospitalName = info.hospitalName
                    this.medRecord = info.medRecord
                    this.images = info.images.map(item => item.url)
                    this.visitDate = new Date(info.visitDate)
                }).catch((error: Error) => {
                    promptAction.showToast(error)
                })
            }
        })
    }
}

@Builder
export function PageBuilder() {
    Page()
}