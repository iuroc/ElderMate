import { BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"
import { CustomContentDialog, SymbolGlyphModifier } from "@kit.ArkUI"
import { preferences } from "@kit.ArkData"
import type { ChatModel } from "@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat"
import { chatModels } from "../config/chatModels"
import { ChatData } from "../utils/db"

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
    controller: CustomDialogController
    @Consume themeColor: BSColorNameMap
    @Consume dataPreferences: preferences.Preferences
    @Consume openaiApiKey: string
    @Consume openaiBaseURL: string
    @Consume openaiCanConfig: boolean
    @Consume currentChatIndex: number
    @Consume chatDataList: ChatData[]

    build() {
        CustomContentDialog({
            primaryTitle: '设置',
            contentBuilder: () => {
                this.Body()
            },
            buttons: [
                {
                    value: '关闭',
                    action: () => {
                        this.controller.close()
                    }
                }
            ]
        })
    }

    @Builder
    Body() {
        Column({ space: 20 }) {
            this.ThemeColorSetting()
            if (this.openaiCanConfig) {
                this.OpenAISetting()
            }
        }
        .margin({
            top: 10,
            bottom: 10
        })
    }

    @Builder
    Title() {
        Text('设置').fontWeight(FontWeight.Bold).fontSize(20)
    }

    @Builder
    ThemeColorSetting() {
        Row({ space: 10 }) {
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
                    this.dataPreferences.putSync('theme_color_name', this.themeColor)
                })
                .value(this.themeColor)
        }
        .width('100%')
    }

    @Builder
    OpenAISetting() {
        Row({ space: 10 }) {
            Text('选择模型')
            Select(chatModels.map(model => {
                const themeColor = getColorGroup(this.themeColor)
                return {
                    value: model,
                    symbolIcon: new SymbolGlyphModifier($r('sys.symbol.minors_mode'))
                        .fontColor([themeColor.main]),
                } as SelectOption
            }))
                .value(this.chatDataList[this.currentChatIndex].model)
                .selected(chatModels.findIndex(model => this.chatDataList[this.currentChatIndex].model == model))
                .layoutWeight(1)
                .onSelect((_index, value) => {
                    this.chatDataList[this.currentChatIndex].model = value as ChatModel
                })
        }

        Row({ space: 10 }) {
            Text('接口密钥')
            TextInput({ placeholder: 'sk-xxxx', text: $$this.openaiApiKey })
                .layoutWeight(1)
                .enableKeyboardOnFocus(false)
        }

        Row({ space: 10 }) {
            Text('接口地址')
            TextInput({ placeholder: 'https://api.openai.com/v1', text: $$this.openaiBaseURL })
                .layoutWeight(1)
                .enableKeyboardOnFocus(false)
        }
    }
}