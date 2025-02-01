@ComponentV2
struct Page {
    build() {
        NavDestination() {
            /**
             * 就诊时间
             * 就诊医院
             * 就诊记录
             * 就诊图片
             */
        }
        .title('我的医疗记录')
    }
}

@Builder
export function PageBuilder() {
    Page()
}