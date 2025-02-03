import { BSColor } from '@iuroc/bootstrap5-color'
import { display, SymbolGlyphModifier } from '@kit.ArkUI'
import { extname, extToMime, formatDateChinese } from '../../../common/utils'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { unifiedDataChannel } from '@kit.ArkData'
import { filePreview } from '@kit.PreviewKit'
import { DragDeleteArea } from '../../Share/Edit/Page'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local visitDate: Date | null = null
    @Local hospitalName: string = ''
    @Local images: string[] = []
    columCount = 3
    columGap = 5
    @Local columHeight: number = 0
    @Local showDeleteArea: boolean = false
    @Local deleteAreaDragEnter: boolean = false

    aboutToAppear(): void {
        const defaultDisplay = display.getDefaultDisplaySync()
        this.columHeight = (
            px2vp(defaultDisplay.width) - (this.columCount - 1) * this.columGap - 30 -
                10 - 64.3
        ) / this.columCount
    }

    build() {
        NavDestination() {

            RelativeContainer() {
                Scroll() {
                    Column({ space: 15 }) {
                        Row({ space: 10 }) {
                            Text('就诊医院')
                            TextInput({ placeholder: '请输入医院名称' })
                                .layoutWeight(1)
                        }

                        Row({ space: 10 }) {
                            Text('就诊日期')
                            Button(this.visitDate == null ? '点击选择就诊日期' : formatDateChinese(this.visitDate))
                                .buttonStyle(ButtonStyleMode.NORMAL)
                                .onClick(() => {
                                    CalendarPickerDialog.show({
                                        selected: this.visitDate,
                                        onAccept: value => {
                                            this.visitDate = value
                                        }
                                    })
                                })
                                .layoutWeight(1)
                        }

                        Row({ space: 10 }) {
                            Text('就诊记录').margin({ top: 10 })
                            TextArea({ placeholder: '请输入就诊记录' })
                                .layoutWeight(1)
                                .constraintSize({ minHeight: 200 })
                                .padding({
                                    top: 10,
                                    bottom: 10
                                })
                        }
                        .alignItems(VerticalAlign.Top)

                        Row({ space: 10 }) {
                            Text('病历上传').margin({ top: 10 })
                            this.ImageSelectBox()
                        }
                        .alignItems(VerticalAlign.Top)
                    }
                    .padding(15)
                }
                .width('100%')
                .height('100%')
                .align(Alignment.Top)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .padding({
                    bottom: 60
                })

                DragDeleteArea(this)
            }
        }
        .title('添加就诊记录')
        .menus([
            {
                value: '确定添加',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                action: () => {

                }
            }
        ])
    }

    @Builder
    ImageSelectBox() {
        Grid() {
            ForEach(this.images, (image: string, index) => {
                GridItem() {
                    Column() {
                        Image(image)
                            .borderRadius(5)
                            .onClick(() => {
                                filePreview.openPreview(getContext(), {
                                    uri: image,
                                    title: '预览图片',
                                    mimeType: extToMime(extname(image))[0]
                                })
                            })
                            .onDragStart(event => {
                                const unifiedData = new unifiedDataChannel.UnifiedData()
                                const text = new unifiedDataChannel.PlainText()
                                text.textContent = index.toString()
                                unifiedData.addRecord(text)
                                event.setData(unifiedData)
                            })
                            .onDragEnd(() => {
                                this.showDeleteArea = false
                            })
                            .onDrop(event => {
                                const record =
                                    event.getData().getRecords()[0] as unifiedDataChannel.PlainText
                                const index1 = parseInt(record.textContent)
                                const index2 = index
                                const temp = this.images[index1]
                                this.images[index1] = this.images[index2]
                                this.images[index2] = temp
                            })
                            .onPreDrag(status => {
                                if (status == PreDragStatus.READY_TO_TRIGGER_DRAG_ACTION) {
                                    this.showDeleteArea = true
                                } else if (status == PreDragStatus.PREVIEW_LANDING_STARTED) {
                                    this.showDeleteArea = false
                                }
                            })
                    }
                    .width('100%')
                    .height(this.columHeight)
                }
            })

            this.AddBox()
        }
        .columnsTemplate(new Array(this.columCount).fill('1fr').join(' '))
        .columnsGap(this.columGap)
        .rowsGap(this.columGap)
        .layoutWeight(1)
        .onTouch(event => {
            if (event.type == TouchType.Down) {
                this.getUIContext().getFocusController().clearFocus()
            }
        })
    }

    @Builder
    AddBox() {
        GridItem() {
            Column() {
                SymbolGlyph($r('sys.symbol.plus')).fontSize(40).fontColor([BSColor.secondary])
                    .fontWeight(FontWeight.Normal)
            }
            .height(this.columHeight)
            .width('100%')
            .backgroundColor('#f7f7f7')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
                const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
                photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
                photoSelectOptions.maxSelectNumber = 100
                photoSelectOptions.isOriginalSupported = true
                photoSelectOptions.preselectedUris = [...this.images]
                const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
                photoViewPicker.select(photoSelectOptions).then(result => {
                    if (result.photoUris.length > 0) {
                        this.images.splice(0)
                        this.images.push(...result.photoUris)
                    }
                })
            })
            .borderRadius(5)
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}
