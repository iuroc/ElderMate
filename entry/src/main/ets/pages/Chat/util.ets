/**
 * 滚动到底部
 * @param scroller
 */
export function scrollToBottom(scroller: Scroller, animation = true) {
    scroller.scrollTo({
        xOffset: 0,
        yOffset: scroller.getItemRect(0).height,
        animation
    })
}
