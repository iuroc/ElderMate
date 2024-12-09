import { BSColor, BSColorNameMap, getColorGroup } from "@iuroc/bootstrap5-color"
import { CustomContentDialog, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { preferences } from "@kit.ArkData"
import type { ChatModel } from "@iuroc/openai/src/main/ets/openai@4.73.1/resources/chat"
import { chatModels as defaultChatModels } from "../config/chatModels"
import { ChatData } from "../utils/db"
import { OpenAI } from "@iuroc/openai"
import { BusinessError } from "@kit.BasicServicesKit"

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
    @State chatModels: ChatModel[] = defaultChatModels
    @State modelsLoading: boolean = true
    @State replaceSelectWithButton: boolean = true

    build() {
        CustomContentDialog({
            primaryTitle: '设置',
            contentBuilder: () => {
                this.Body()
            },
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

    aboutToAppear(): void {
        if (this.openaiCanConfig) {
            this.getModelNamesFromAPI().then(result => {
                this.chatModels = result || defaultChatModels
                this.modelsLoading = false
                this.replaceSelectWithButton = false
            })
        }
    }

    @Builder
    OpenAISetting() {
        Row({ space: 10 }) {
            Text('选择模型')
            if (this.replaceSelectWithButton) {
                Button({
                    type: ButtonType.Capsule,
                    stateEffect: true,
                    buttonStyle: ButtonStyleMode.NORMAL
                }) {
                    Row() {
                        if (this.modelsLoading) {
                            LoadingProgress()
                                .width(30).height(30)
                                .margin({ right: 5 })
                        }
                        Text(this.modelsLoading ? '正在加载模型列表' : '加载模型列表')
                    }.alignItems(VerticalAlign.Center).height(40)
                }
                .enabled(!this.modelsLoading)
                .layoutWeight(1)
                .onClick(() => {
                    this.modelsLoading = true
                    this.getModelNamesFromAPI().then(result => {
                        this.chatModels = result || defaultChatModels
                        this.replaceSelectWithButton = false
                    }).catch(() => {
                        promptAction.showToast({ message: '加载模型列表失败' })
                    }).finally(() => {
                        this.modelsLoading = false
                    })
                })
            } else {
                Select(this.chatModels.map(model => {
                    const themeColor = getColorGroup(this.themeColor)
                    return {
                        value: model,
                        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.minors_mode'))
                            .fontColor([themeColor.main]),
                    } as SelectOption
                }))
                    .value(this.modelsLoading ? '正在加载模型列表' : this.chatDataList[this.currentChatIndex].model)
                    .selected(this.chatModels.findIndex(model => this.chatDataList[this.currentChatIndex].model ==
                        model))
                    .layoutWeight(1)
                    .enabled(!this.modelsLoading)
                    .onSelect((_index, value) => {
                        this.chatDataList[this.currentChatIndex].model = value as ChatModel
                    })
            }
        }

        Row({ space: 10 }) {
            Text('接口密钥')
            TextInput({ placeholder: 'sk-xxxx', text: $$this.openaiApiKey })
                .layoutWeight(1)
                .onChange(() => {
                    this.replaceSelectWithButton = true
                })
                .enableKeyboardOnFocus(false)
        }

        Row({ space: 10 }) {
            Text('接口地址')
            TextInput({ placeholder: 'https://api.openai.com/v1', text: $$this.openaiBaseURL })
                .layoutWeight(1)
                .onChange(() => {
                    this.replaceSelectWithButton = true
                })
                .enableKeyboardOnFocus(false)
        }
    }

    async getModelNamesFromAPI(): Promise<ChatModel[]> {
        const openai = new OpenAI({
            apiKey: this.openaiApiKey,
            baseURL: this.openaiBaseURL
        })
        const modelsPromise = openai.models.list({
            requestConfiguration: {
                proxy: 'system',
                security: {
                    remoteValidation: 'skip'
                },
                transfer: {
                    timeout: { connectMs: 10000 }
                }
            }
        })
        modelsPromise.catch((error: BusinessError<string>) => {
            this.modelsLoading = false
        })
        const models = await modelsPromise
        return models.map(model => {
            return model.id as ChatModel
        })
    }
}