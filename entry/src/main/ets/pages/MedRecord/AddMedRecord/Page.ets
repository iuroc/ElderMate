import { BSColor } from '@iuroc/bootstrap5-color'
import { CustomContentDialog, display, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { extname, extToMime, formatDateChinese } from '../../../common/utils'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { unifiedDataChannel } from '@kit.ArkData'
import { filePreview } from '@kit.PreviewKit'
import { DragDeleteArea, UploadResult } from '../../Share/Edit/Page'
import { uploadImage } from '../../Share/utils'
import { ApiResponse } from '../../../common/types'
import { AddMedRecordPopResult, createMedRecord, CreateMedRecordConfig } from './utils'
import { BusinessError } from '@kit.BasicServicesKit'
import { getMedRecordInfo } from '../ViewMedRecord/utils'
import { apiOrigin } from '../../../common/config'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local visitDate: Date | null = null
    @Local hospitalName: string = ''
    @Local medRecord: string = ''
    @Local images: string[] = []
    private columCount = 3
    private columGap = 5
    @Local columHeight: number = 0
    @Local showDeleteArea: boolean = false
    @Local deleteAreaDragEnter: boolean = false
    private progressDialogId = 0
    /** 该值在页面载入时由路由载入 */
    @Local editId: number | null = null

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
                            TextInput({ placeholder: '请输入医院名称', text: $$this.hospitalName })
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
                            TextArea({ placeholder: '请输入就诊记录', text: $$this.medRecord })
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
                isEnabled: this.hospitalName.trim() != '' && this.visitDate != null &&
                    (this.medRecord.trim() != '' || this.images.length > 0),
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                action: () => {
                    if (this.images.length > 0) {
                        const imageURLs: string[] = []
                        promptAction.openCustomDialog({
                            builder: () => {
                                this.ProgressDialog()
                            },
                            autoCancel: false
                        }).then(dialogId => this.progressDialogId = dialogId)
                        uploadImage(this.images).then(task => {
                            task.on('complete', () => {
                                this.create(imageURLs)
                            })
                            task.on('headerReceive', (header) => {
                                const body = JSON.parse((header as UploadResult).body) as ApiResponse<string[]>
                                imageURLs.push(body.data[0])
                            })
                        })
                    } else {
                        this.create()
                    }
                }
            }
        ])
        .onWillAppear(() => {
            const params = this.pathInfos.getParamByName('AddMedRecord') as object[]
            if (params.length > 0 && typeof params[0] == 'number') {
                this.editId = params[0] as number
                getMedRecordInfo(this.editId).then(info => {
                    this.visitDate = new Date(info.visitDate)
                    this.hospitalName = info.hospitalName
                    this.medRecord = info.medRecord
                    this.images = info.images.map(item => apiOrigin + item.url)
                })
            }
        })
    }

    @Builder
    ProgressDialog() {
        Column() {
            CustomContentDialog({
                primaryTitle: '正在提交',
                contentBuilder: () => {
                    this.ProgressDialogContent()
                },
                buttons: [
                    {
                        value: '取消提交',
                        fontColor: BSColor.danger,
                        action: () => {
                            promptAction.closeCustomDialog(this.progressDialogId)
                            this.pathInfos.pop()
                        }
                    }
                ]
            })
        }
    }

    @Builder
    ProgressDialogContent() {
        Text('请稍等片刻，马上就好~')
    }

    create(imageURLs: string[] = []) {
        const config = {
            hospitalName: this.hospitalName,
            visitDate: this.visitDate as Date,
            medRecord: this.medRecord,
            imageURLs
        } as CreateMedRecordConfig
        createMedRecord(config).then(result => {
            promptAction.closeCustomDialog(this.progressDialogId)
            this.pathInfos.pop({
                result,
                config,
                imageURLs
            } as AddMedRecordPopResult)
        }).catch((error: BusinessError) => {
            promptAction.closeCustomDialog(this.progressDialogId)
            AlertDialog.show({
                title: '提交失败',
                message: error.message,
                buttons: [
                    {
                        value: '稍后重试',
                        action: () => {
                        },
                        fontColor: BSColor.secondary
                    }
                ]
            })
        })
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
