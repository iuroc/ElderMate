import { ChatPage } from '@iuroc/chat-page'
import { preferences, relationalStore } from '@kit.ArkData'

const dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'chat' })
const getRdbStore = async () => {
    // await relationalStore.deleteRdbStore(getContext(), 'chat.db')
    return relationalStore.getRdbStore(getContext(), {
        name: 'chat.db',
        securityLevel: relationalStore.SecurityLevel.S1
    })
}

@Builder
export function PageBuilder() {
    ChatPage({ dataPreferences, getRdbStore })
}