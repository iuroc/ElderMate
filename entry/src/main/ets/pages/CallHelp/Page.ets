@Builder
export function PageBuilder() {
    Page()
}

@Component
struct Page {
    build() {
        Text('紧急求助')
    }
}