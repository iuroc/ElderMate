import { preferences } from "@kit.ArkData"
import { apiOrigin } from "../../common/config"
import { http } from "@kit.NetworkKit"
import { ApiResponse } from "../../common/types"

/** 根据当前时间返回问候语 */
export async function getGreeting(): Promise<string> {
    const resourceManager = getContext().resourceManager
    const now = new Date()
    const hours = now.getHours()
    let greeting = ''
    if (hours < 5) {
        greeting = await resourceManager.getStringValue($r('app.string.greeting_good_night'))
    } else if (hours < 12) {
        greeting = await resourceManager.getStringValue($r('app.string.greeting_good_morning'))
    } else if (hours < 14) {
        greeting = await resourceManager.getStringValue($r('app.string.greeting_good_noon'))
    } else if (hours < 18) {
        greeting = await resourceManager.getStringValue($r('app.string.greeting_good_afternoon'))
    } else if (hours < 24) {
        greeting = await resourceManager.getStringValue($r('app.string.greeting_good_evening'))
    }
    return greeting
}