import { AbilityConstant, UIAbility, common, Want, abilityAccessCtrl } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { calendarManager } from '@kit.CalendarKit'

export let _calendarManager: calendarManager.CalendarManager | null = null

export let mContext: common.UIAbilityContext

export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate')
    }

    onDestroy(): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy')
    }

    onWindowStageCreate(windowStage: window.WindowStage): void {
        // Main window is created, set main page for this ability
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate')

        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s',
                    JSON.stringify(err) ?? '')
                return
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.')
        })

        mContext = this.context
        initCalendarManager().catch((error: Error) => {
            console.error(error.message)
        })
    }

    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy')
    }

    onForeground(): void {
        // Ability has brought to foreground
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground')
    }

    onBackground(): void {
        // Ability has back to background
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground')
    }
}

/** @throws Error */
const initCalendarManager = async () => {
    const atManager = abilityAccessCtrl.createAtManager()
    const result = await atManager.requestPermissionsFromUser(mContext, [
        'ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'
    ])
    if (result.authResults.filter(i => i != 0).length > 0) {
        throw new Error('未授权日历读写权限')
    }
    _calendarManager = calendarManager.getCalendarManager(mContext)
}
