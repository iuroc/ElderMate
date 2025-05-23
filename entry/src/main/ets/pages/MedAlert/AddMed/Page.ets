import { BSColor } from "@iuroc/bootstrap5-color"
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { formatDateChinese } from "../../../common/utils"
import {
    createMedAlert,
    CreateMedAlertConfig,
    CreateMedAlertResult,
    daysBetweenInclusive,
    isABeforeB,
    isBeforeToday
} from "./utils"

@ComponentV2
struct Page {
    @Local i_name: string = '' // 强效缓释镇痛胶囊XK-750
    @Local i_countPerDay: string = '' // 2
    @Local i_description: string = '' // 饭后服用，避免与酒精同服
    @Local startDate?: Date = new Date()
    @Local endDate?: Date = new Date()
    editId?: number
    createTime?: Date
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    menuEnabled() {
        return !!this.i_name && parseInt(this.i_countPerDay) > 0 && !!this.startDate && !!this.endDate
    }

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 15 }) {
                    Row({ space: 10 }) {
                        Text('药品名称').fontWeight(FontWeight.Medium)
                        TextArea({ placeholder: '药品名称', text: $$this.i_name })
                            .layoutWeight(1)
                            .maxLines(3)
                            .defaultFocus(true)
                    }

                    Row({ space: 10 }) {
                        Text('每日次数').fontWeight(FontWeight.Medium)
                        TextInput({ placeholder: '每天吃几次，比如 3 次', text: $$this.i_countPerDay })
                            .layoutWeight(1)
                            .type(InputType.Number)
                    }

                    Row({ space: 10 }) {
                        Text('用药说明').fontWeight(FontWeight.Medium)
                        TextArea({ placeholder: '比如饭后服用、孕妇慎用', text: $$this.i_description })
                            .layoutWeight(1)
                            .maxLines(3)
                    }

                    Row({ space: 10 }) {
                        Text() {
                            Span(`请选择用药的日期范围`).fontWeight(FontWeight.Medium)
                            Span(this.startDate && this.endDate
                                ? `（已选择 ${daysBetweenInclusive(this.startDate, this.endDate)} 天）`
                                : '')
                                .fontWeight(FontWeight.Bold)
                                .fontColor(BSColor.primary)
                        }
                    }
                    .width('100%')
                    .padding({ top: 10, bottom: 10 })

                    Row({ space: 10 }) {
                        Button(this.startDate ? formatDateChinese(this.startDate) : '起始日期')
                            .layoutWeight(1)
                            .buttonStyle(ButtonStyleMode.NORMAL)
                            .onClick(() => {
                                CalendarPickerDialog.show({
                                    selected: this.startDate,
                                    onAccept: value => {
                                        if (isBeforeToday(value)) {
                                            promptAction.showToast({ message: '起始日期不能比今天更早' })
                                        } else {
                                            this.startDate = value
                                            if (!this.endDate) {
                                                this.endDate = this.startDate
                                            }
                                            if (isABeforeB(this.endDate, this.startDate)) {
                                                this.endDate = this.startDate
                                            }
                                        }
                                    }
                                })
                            })
                        SymbolGlyph($r('sys.symbol.arrow_right'))
                        Button(this.endDate ? formatDateChinese(this.endDate) : '结束日期')
                            .enabled(!!this.startDate)
                            .layoutWeight(1)
                            .buttonStyle(ButtonStyleMode.NORMAL)
                            .onClick(() => {
                                CalendarPickerDialog.show({
                                    selected: this.endDate,
                                    onAccept: value => {
                                        if (isABeforeB(value, this.startDate || new Date())) {
                                            promptAction.showToast({ message: '结束日期不能比起始日期更早' })
                                        } else {
                                            this.endDate = value
                                        }
                                    },
                                })
                            })
                    }
                }
                .padding(15)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .title(this.editId == null ? '新增用药' : '编辑用药')
        .menus([
            {
                value: '确定',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                action: () => {
                    const config = {
                        name: this.i_name.trim(),
                        useCountPerDay: parseInt(this.i_countPerDay),
                        description: this.i_description,
                        startDate: this.startDate,
                        endDate: this.endDate,
                        id: this.editId
                    } as CreateMedAlertConfig
                    createMedAlert(config).then(result => {
                        config.id = this.editId
                        this.pathInfos.pop({
                            result: result || {
                                id: this.editId,
                                createTime: this.createTime
                            },
                            config
                        } as AddMedPagePopResult)
                    }).catch((error: Error) => {
                        promptAction.showToast(error)
                    })
                },
                isEnabled: this.menuEnabled()
            }
        ])
        .onWillAppear(() => {
            const config = this.pathInfos.getParamByName('AddMed')[0] as CreateMedAlertConfig
            if (config) {
                this.i_name = config.name
                this.i_countPerDay = config.useCountPerDay.toString()
                this.i_description = config.description
                this.startDate = config.startDate
                this.endDate = config.endDate
                this.editId = config.id
                this.createTime = config.createTime
            }
        })
    }
}

export interface AddMedPagePopResult {
    result: CreateMedAlertResult
    config: CreateMedAlertConfig
}

@Builder
export function PageBuilder() {
    Page()
}