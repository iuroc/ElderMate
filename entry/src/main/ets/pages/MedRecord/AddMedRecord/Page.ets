import { SymbolGlyphModifier } from '@kit.ArkUI'
import { formatDateChinese } from '../../../common/utils'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local visitDate: Date | null = null
    @Local hospitalName: string = ''

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 15 }) {
                    Row({ space: 10 }) {
                        Text('就诊医院')
                        TextArea({ placeholder: '请输入医院名称' })
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
                        Text('就诊医院')
                        TextArea({ placeholder: '请输入医院名称' })
                            .layoutWeight(1)
                    }
                }
                .padding(15)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .title('页面标题')
        .menus([
            {
                value: '确定添加',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                action: () => {

                }
            }
        ])
    }
}

@Builder
export function PageBuilder() {
    Page()
}
