@Entry
struct Page {
    build() {
        NavDestination() {

        }.title('帖子审核')
    }
}

@Builder
export function PageBuilder() {
    Page()
}