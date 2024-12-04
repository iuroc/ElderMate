import { BSColor, BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"
import { SymbolGlyphModifier } from "@kit.ArkUI"

const colorNameMap: Array<BSColorNameMap> = [
    'success',
    'danger',
    'primary',
    'secondary',
    'dark',
    'warning',
    'info',
]

@CustomDialog
export struct SettingDialog {
    controller: CustomDialogController = new CustomDialogController({
        builder: SettingDialog({}),
    })
    @Consume themeColor: BSColorNameMap

    build() {
        Column({ space: 20 }) {
            this.Title()
            this.Body()
        }
        .width('100%')
        .padding(25)
    }

    @Builder
    Body() {
        Column({ space: 20 }) {
            this.ThemeColorSetting()
        }
    }

    @Builder
    Title() {
        Text('设置').fontWeight(FontWeight.Bold).fontSize(20)
    }

    @Builder
    ThemeColorSetting() {
        Row({ space: 15 }) {
            Text('主题颜色')
            Select(colorNameMap.map(name => {
                return {
                    symbolIcon: new SymbolGlyphModifier($r('sys.symbol.solid_color_mixing'))
                        .fontColor([getColorGroup(name).main]),
                    value: name
                } as SelectOption
            }))
                .layoutWeight(1)
                .backgroundColor(getColorGroup(this.themeColor).background)
                .selectedOptionBgColor(getColorGroup(this.themeColor).background)
                .selectedOptionFontColor(getColorGroup(this.themeColor).font)
                .selected(colorNameMap.findIndex(name => name == this.themeColor))
                .onSelect((_index, value) => {
                    this.themeColor = value as BSColorNameMap
                })
                .value(this.themeColor)
        }
        .width('100%')
    }
}