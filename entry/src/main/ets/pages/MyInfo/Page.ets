import { SymbolGlyphModifier } from "@kit.ArkUI"
import { formatDateChinese } from "../../common/utils"
import { getInfo, updateInfo } from "./utils"

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    /**
     * 真实姓名
     */
    @Local name: string = ''
    /**
     * 是否是男性
     */
    @Local isMan: boolean | null = null
    /**
     * 联系电话
     */
    @Local callPhone: string = ''
    /**
     * 身份证号
     */
    @Local idNumber: string = ''
    /**
     * 出生日期
     */
    @Local birthday: Date | null = null
    /**
     * 血型
     */
    @Local bloodType: string = ''
    /**
     * 居住地址
     */
    @Local address: string = ''
    /**
     * 家人留言
     */
    @Local familyMessage: string = ''
    /**
     * 个人简介
     */
    @Local intro: string = ''
    /**
     * 当前是否是编辑模式
     */
    @Local editMode: boolean = false

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 10 }) {
                    TextField({
                        label: '真实姓名',
                        placeholder: '真实姓名',
                        value: this.name,
                        editMode: this.editMode,
                        onChange: value => {
                            this.name = value
                        }
                    })

                    Row({ space: 10 }) {
                        Text() {
                            Span('性别').fontColor(Color.Transparent)
                            Span('性别')
                        }.fontWeight(FontWeight.Bold)

                        if (this.editMode) {
                            Select([
                                {
                                    value: '男',
                                    icon: $r('app.media.man')
                                },
                                {
                                    value: '女',
                                    icon: $r('app.media.woman')
                                }
                            ])
                                .value(this.isMan == null ? '选择性别' : (this.isMan ? '男' : '女'))
                                .onSelect((_index, value) => {
                                    this.isMan = value == '男'
                                })
                                .selected(this.isMan ? 0 : 1)
                        } else {
                            TextInput({ text: this.isMan == null ? '暂未设置' : (this.isMan ? '男' : '女') })
                                .layoutWeight(1)
                                .backgroundColor(Color.Transparent)
                                .enabled(false)
                        }
                    }.width('100%')

                    TextField({
                        label: '联系电话',
                        placeholder: '联系电话',
                        value: this.callPhone,
                        editMode: this.editMode,
                        type: InputType.PhoneNumber,
                        onChange: value => {
                            this.callPhone = value
                        }
                    })

                    TextField({
                        label: '身份证号',
                        placeholder: '身份证号',
                        value: this.idNumber,
                        editMode: this.editMode,
                        type: InputType.Number,
                        onChange: value => {
                            this.idNumber = value
                        }
                    })

                    Row({ space: 10 }) {
                        Text('出生日期').fontWeight(FontWeight.Bold)
                        if (this.editMode) {
                            Button(this.birthday ? formatDateChinese(this.birthday) : '选择日期')
                                .onClick(() => {
                                    CalendarPickerDialog.show({
                                        selected: this.birthday,
                                        onAccept: value => {
                                            this.birthday = value
                                        }
                                    })
                                })
                                .buttonStyle(ButtonStyleMode.NORMAL)
                        } else {
                            TextInput({ text: this.birthday ? formatDateChinese(this.birthday) : '暂未设置' })
                                .layoutWeight(1)
                                .enabled(false)
                                .backgroundColor(Color.Transparent)
                        }
                    }.width('100%')

                    TextField({
                        label: '血型',
                        placeholder: '血型',
                        value: this.bloodType,
                        editMode: this.editMode,
                        onChange: value => {
                            this.bloodType = value
                        }
                    })

                    TextField({
                        label: '居住地址',
                        placeholder: '居住地址',
                        value: this.address,
                        editMode: this.editMode,
                        onChange: value => {
                            this.address = value
                        }
                    })

                    TextField({
                        label: '家人留言',
                        placeholder: '家人留言',
                        value: this.familyMessage,
                        editMode: this.editMode,
                        onChange: value => {
                            this.familyMessage = value
                        }
                    })

                    TextField({
                        label: '个人介绍',
                        placeholder: '个人介绍',
                        value: this.intro,
                        editMode: this.editMode,
                        onChange: value => {
                            this.intro = value
                        }
                    })

                    if (!this.editMode) {
                        Row({ space: 10 }) {
                            Button('就诊记录').buttonStyle(ButtonStyleMode.NORMAL)
                                .onClick(() => {
                                    this.pathInfos.pushPath({ name: 'MedRecord' })
                                })
                                .layoutWeight(1)
                            Button('用药记录').buttonStyle(ButtonStyleMode.NORMAL)
                                .onClick(() => {
                                    this.pathInfos.pushPath({ name: 'MedAlert' })
                                })
                                .layoutWeight(1)
                        }

                        Row({ space: 10 }) {
                            Button('生活动态').buttonStyle(ButtonStyleMode.NORMAL)
                                .onClick(() => {
                                    this.pathInfos.pushPath({ name: 'Share' })
                                })
                                .layoutWeight(1)
                            Button('紧急联系人').buttonStyle(ButtonStyleMode.NORMAL)
                                .onClick(() => {
                                    this.pathInfos.pushPath({ name: 'CallHelp' })
                                })
                                .layoutWeight(1)
                        }
                    }
                }
                .padding(15)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .title('我的个人信息')
        .onWillAppear(() => {
            getInfo().then(result => {
                this.name = result.name || ''
                this.isMan = result.isMan == null ? null : (result.isMan == 1)
                this.callPhone = result.callPhone || ''
                this.idNumber = result.idNumber || ''
                this.birthday = result.birthday ? new Date(result.birthday) : null
                this.bloodType = result.bloodType || ''
                this.address = result.address || ''
                this.familyMessage = result.familyMessage || ''
                this.intro = result.intro || ''
            }).catch(AlertDialog.show)
        })
        .menus([{
            value: this.editMode ? '退出编辑' : '进入编辑',
            symbolIcon: new SymbolGlyphModifier(this.editMode ? $r('sys.symbol.checkmark') :
            $r('sys.symbol.square_and_pencil')),
            action: () => {
                if (this.editMode) {
                    updateInfo({
                        address: this.address,
                        birthday: this.birthday == null ? null : new Date(this.birthday).getTime().toString(),
                        isMan: this.isMan == null ? null : (this.isMan ? 1 : 0),
                        callPhone: this.callPhone,
                        familyMessage: this.familyMessage,
                        bloodType: this.bloodType,
                        idNumber: this.idNumber,
                        intro: this.intro,
                        name: this.name
                    }).then(() => {
                        this.editMode = false
                    }).catch((error: Error) => {
                        AlertDialog.show(error)
                    })
                } else {
                    this.editMode = true
                }
            }
        }])
    }
}

@ComponentV2
struct TextField {
    @Require @Param editMode: boolean
    @Require @Param label: string
    @Require @Param value: string
    @Param placeholder: string = ''
    @Event onChange: (event: string) => void
    @Param type: InputType = InputType.Normal

    build() {
        Row({ space: 10 }) {
            Text() {
                Span('信'.repeat(4 - this.label.length)).fontColor(Color.Transparent)
                Span(this.label)
            }.fontWeight(FontWeight.Bold)

            if (this.editMode) {
                TextInput({ text: this.value, placeholder: this.placeholder }).layoutWeight(1).type(this.type)
                    .onChange(this.onChange)
            } else {
                TextInput({ text: this.value || '暂未设置' })
                    .layoutWeight(1)
                    .enabled(false)
                    .backgroundColor(Color.Transparent)
            }
        }.width('100%').justifyContent(FlexAlign.Start)
    }
}

@Builder
export function PageBuilder() {
    Page()
}