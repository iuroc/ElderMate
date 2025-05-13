import { SymbolGlyphModifier, window } from '@kit.ArkUI'
import { loginOrRegister, saveToken, saveUserInfo, sendVerCode, User } from './utils'
import { BusinessError } from '@kit.BasicServicesKit'

@ComponentV2
struct Page {
    build() {
        NavDestination() {
            PageContent()
        }
        .title('登录注册页面')
        .hideTitleBar(true)
        .onBackPressed(() => {
            if (canIUse('SystemCapability.Window.SessionManager')) {
                window.getLastWindow(getContext()).then(lastWindow => lastWindow.minimize())
            }
            return true
        })
    }
}

@ComponentV2
struct PageContent {
    @Local phone: string = '' // 生产环境置空
    @Local verCode: string = '' // 生产环境置空
    @Local password: string = '' // 生产环境置空
    @Local loginMode: 'verCode' | 'password' = 'verCode'
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Consumer() isAdmin: boolean = false

    sendVerCodeBtnText() {
        return this.secondsLeft == 0 ? '发送验证码' : `${this.secondsLeft}秒后重试`
    }

    /** 输入的手机号码是否合法 */
    phoneAllow() {
        return !!this.phone.match(/^\d{11}$/)
    }

    /** 输入的验证码是否合法 */
    verCodeAllow() {
        return !!this.verCode.match(/^\d{6}$/)
    }

    /** 输入的密码是否合法 */
    allowPassword() {
        return !!this.password.match(/^\S{8,32}$/)
    }

    @Local loginRequesting: boolean = false
    @Local allowSendVerCode: boolean = true
    /** 多少秒钟后可以重试发送验证码 */
    @Local secondsLeft: number = 0
    /** 发送验证码的计时器 */
    sendVerCodeTimer: number = 0

    build() {
        Navigation() {
            Scroll() {
                Column({ space: 20 }) {
                    TextInput({
                        placeholder: '请输入手机号登录或注册',
                        text: $$this.phone
                    })
                        .type(InputType.PhoneNumber)
                    if (this.loginMode == 'verCode') {
                        Row({ space: 15 }) {
                            TextInput({ placeholder: '请输入验证码', text: $$this.verCode })
                                .layoutWeight(1)
                                .type(InputType.Number)
                            this.SendVerCodeButton()
                        }
                    } else {
                        TextInput({ placeholder: '请输入密码，8-32位', text: $$this.password })
                            .type(InputType.Password)
                            .showPassword(false)
                    }
                    this.LoginButton()
                    this.ChangeLoginMode()
                }
                .width('100%')
                .padding(15)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Top)
        }
        .title('用户登录')
        .titleMode(NavigationTitleMode.Full)
        .menus(this.navMenus())
    }

    loginButtonEnabled() {
        return this.phoneAllow() && (this.verCodeAllow() || this.allowPassword()) && !this.loginRequesting
    }

    clickLogin(isAdmin = false) {
        this.loginRequesting = true
        if (this.loginMode == 'verCode') {
            this.password = ''
        } else if (this.loginMode == 'password') {
            this.verCode = ''
        }
        loginOrRegister(this.phone, this.verCode, this.password, isAdmin).then(result => {
            if (result.success) {
                // 登录成功
                saveUserInfo(result.data.user)
                saveToken(result.data.token)
                this.isAdmin = result.data.user.role == 'admin'
                this.pathInfos.pop(false)
            } else {
                this.showLoginErrorDialog(result.message)
            }
        }).catch((error: BusinessError) => {
            this.showLoginErrorDialog(error.message)
        }).finally(() => this.loginRequesting = false)
    }

    @Builder
    LoginButton() {
        Button('登录').width('100%').padding({ top: 5, bottom: 5 })
            .enabled(this.loginButtonEnabled())
            .onClick(() => {
                this.clickLogin(false)
            })
    }

    showLoginErrorDialog(reason: string) {
        this.getUIContext().getFocusController().clearFocus()
        AlertDialog.show({
            title: '登录失败',
            message: reason,
            primaryButton: {
                value: '关闭',
                action: () => {
                }
            }
        })
    }

    @Builder
    ChangeLoginMode() {
        Row({ space: 10 }) {
            Button(this.loginMode == 'verCode' ? '使用密码登录' : '使用验证码登录')
                .layoutWeight(1)
                .buttonStyle(ButtonStyleMode.NORMAL)
                .onClick(() => {
                    this.loginMode = this.loginMode == 'verCode' ? 'password' : 'verCode'
                    this.verCode = this.password = ''
                })
            if (this.loginMode == 'password') {
                Button('管理员登录')
                    .layoutWeight(1)
                    .enabled(this.loginButtonEnabled())
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .onClick(() => {
                        this.clickLogin(true)
                    })
            }
        }
    }

    @Builder
    SendVerCodeButton() {
        Button(this.sendVerCodeBtnText())
            .enabled(this.phoneAllow() && this.allowSendVerCode)
            .buttonStyle(ButtonStyleMode.NORMAL)
            .onClick(() => {
                this.allowSendVerCode = false
                this.secondsLeft = 60
                this.restartVerCodeTimer()
                sendVerCode(this.phone).then(result => {
                    if (!result.success) {
                        this.showVerCodeSendErrorDialog(result.message)
                    }
                }).catch((error: BusinessError) => {
                    this.showVerCodeSendErrorDialog(error.message)
                })
            })
    }

    /** 重启定时器，将清除当前正在运行的定时器 */
    restartVerCodeTimer() {
        clearInterval(this.sendVerCodeTimer)
        this.sendVerCodeTimer = setInterval(() => {
            this.secondsLeft-- // 放第一行，是因为第一次定时器回调函数执行时，已经至少过去了一秒钟
            if (this.secondsLeft == 0) {
                this.allowSendVerCode = true
                clearInterval(this.sendVerCodeTimer)
                return
            }
        }, 1000)
    }

    showVerCodeSendErrorDialog(reason: string) {
        this.secondsLeft = 10
        this.restartVerCodeTimer()
        AlertDialog.show({
            title: '验证码发送失败',
            message: `失败原因：${reason}，您可在 10 秒后重新发送验证码。`,
            primaryButton: {
                value: '好的',
                action: () => {
                }
            },
        })
    }

    navMenus(): NavigationMenuItem[] {
        return [
            {
                value: '帮助',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')),
                action: async () => {
                    const resourceManager = getContext().resourceManager
                    const title = await resourceManager.getStringValue($r('app.string.login_help_title'))
                    const message = await resourceManager.getStringValue($r('app.string.login_help_message'))
                    const btnText = await resourceManager.getStringValue($r('app.string.button_confirm_dialog'))
                    AlertDialog.show({
                        title,
                        message,
                        primaryButton: {
                            value: btnText,
                            action: () => {
                            }
                        }
                    })
                }
            }
        ]
    }
}

@Builder
export function PageBuilder() {
    Page()
}