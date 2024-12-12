import { MainPage as ChatPage } from '@iuroc/chat-page-v2'
import { preferences, relationalStore } from '@kit.ArkData'

@ComponentV2
struct Page {
    build() {
        ChatPage({
            dataPreferences: preferences.getPreferencesSync(getContext(), { name: 'chat_page' }),
            loadRdbStore: async () => {
                // await relationalStore.deleteRdbStore(getContext(), 'chat_page.db')
                return relationalStore.getRdbStore(
                    getContext(),
                    {
                        name: 'chat_page.db',
                        securityLevel:
                        relationalStore.SecurityLevel.S1
                    }
                )
            }
        })
    }
}

@Builder
export function PageBuilder() {
    Page()
}