import { MainPage as ChatPage } from '@iuroc/chat-page-v2'

@ComponentV2
struct Page {
    build() {
        ChatPage()
    }
}

@Builder
export function PageBuilder() {
    Page()
}