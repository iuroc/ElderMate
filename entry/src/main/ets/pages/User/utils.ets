import { preferences } from '@kit.ArkData'

/**
 * 清除本地的用户数据，该操作将直接删除整个 user preferences
 */
export function clearUserData() {
    return preferences.deletePreferences(getContext(), 'user')
}

