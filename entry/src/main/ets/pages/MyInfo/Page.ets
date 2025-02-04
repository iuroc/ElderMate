@ComponentV2
struct Page {
    build() {
        NavDestination() {

        }
        .title('我的个人信息')
    }
}

@Builder
export function PageBuilder() {
    Page()
}