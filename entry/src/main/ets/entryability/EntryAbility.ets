import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { window, KeyboardAvoidMode } from '@kit.ArkUI'

export default class EntryAbility extends UIAbility {
    onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
        const applicationContext = this.context.getApplicationContext()
        applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    }

    onDestroy(): void {
    }

    async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
        try {
            await windowStage.loadContent('pages/Index/Page')
            await this.contentLoaded(windowStage)
        } catch (error) {
            console.error(JSON.stringify(error))
        }
    }

    onWindowStageDestroy(): void {
    }

    onForeground(): void {
    }

    onBackground(): void {
    }

    async contentLoaded(windowStage: window.WindowStage) {
        const mainWindow = await windowStage.getMainWindow()
        const uiContext = mainWindow.getUIContext()
        uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    }
}