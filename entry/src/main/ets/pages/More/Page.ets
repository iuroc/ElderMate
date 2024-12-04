@Component
struct Page {
    build() {
        NavDestination() {
            TextArea()
        }
    }
}

@Builder
export function PageBuilder() {
    Page()
}