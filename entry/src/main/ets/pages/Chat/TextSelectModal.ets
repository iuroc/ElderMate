import { LengthMetrics } from "@kit.ArkUI"
import { systemShare } from "@kit.ShareKit"
import { uniformTypeDescriptor } from "@kit.ArkData"
import { systemShareText } from "./util"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

@Component
export struct TextSelectModal {
    @Prop text: string
    controller = new TextController()
    start: number = 0
    end: number = 0
    shareTextTitle: string = ''

    async aboutToAppear() {
        const resourceManager = getContext().resourceManager
        const resource = $r('app.string.ChatPage_TextSelectModal_text_share_title')
        this.shareTextTitle = await resourceManager.getStringValue(resource)
    }

    build() {
        Scroll() {
            Column({ space: 20 }) {
                Text(this.text, { controller: this.controller })
                    .fontSize(20)
                    .copyOption(CopyOptions.InApp)
                    .selection(this.start, this.end)
                    .lineSpacing(LengthMetrics.vp(10))
                    .letterSpacing(1)
                    .textAlign(TextAlign.JUSTIFY)
                    .onTextSelectionChange((start, end) => {
                        this.start = start
                        this.end = end
                    })
                Button('将所选内容分享给朋友')
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .onClick(() => {
                        systemShareText(
                            getContext(this) as common.UIAbilityContext,
                            this.shareTextTitle,
                            this.text.slice(this.start, this.end),
                        ).catch((error: BusinessError) => {
                            console.error(error.message)
                        })
                    })
            }.padding(20)
        }
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
    }
}
