@Entry
@Component
struct Index {
    @State num: number = 0
    numBack = this.num
    getNum = () => this.num
    @State list: number[] = [
        this.num
    ]
    @State mm: number = this.num

    aboutToAppear(): void {
        this.num = 100
    }

    build() {
        Column() {
            Text(this.num.toString()) // 显示 100
            Text(this.getNum().toString()) // 显示 100
            Text(this.numBack.toString()) // 显示 0
            Text(this.list[0].toString()) // 显示 0
            Text(this.mm.toString()) // 显示 0
        }
    }
}