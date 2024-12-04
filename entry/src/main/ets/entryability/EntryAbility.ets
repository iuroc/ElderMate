import { UIAbility } from '@kit.AbilityKit'
import { KeyboardAvoidMode, window } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
    async onWindowStageCreate(windowStage: window.WindowStage) {
        await windowStage.loadContent('pages/Index/Page')
        await contentLoaded(windowStage)
    }
}

async function contentLoaded(windowStage: window.WindowStage) {
    const mainWindow = await windowStage.getMainWindow()
    const uiContext = mainWindow.getUIContext()
    uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
}