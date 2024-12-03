import { UIAbility } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
    async onWindowStageCreate(windowStage: window.WindowStage) {
        await windowStage.loadContent('pages/Index/Page')
        contentLoaded(windowStage)
    }
}

function contentLoaded(windowStage: window.WindowStage) {

}