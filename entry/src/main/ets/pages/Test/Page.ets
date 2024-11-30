import { Card } from "./Card"

@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    build() {
        NavDestination() {
            Flex() {
                Card()
            }
        }
        .title('测试页面')
    }
}

