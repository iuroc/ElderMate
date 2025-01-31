import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { ApiResponse } from '../../common/types'
import { url } from '@kit.ArkTS'
import { preferences } from '@kit.ArkData'

/**
 * 发送验证码
 * @param phone 待接收验证码的手机号
 * @returns `success` 参数判断是否发送成功，`message` 详细信息
 */
export async function sendVerCode(phone: string) {
    const request = http.createHttp()
    const response = await request.request(`${apiOrigin}/api/user/verCode/send`, {
        method: http.RequestMethod.POST,
        extraData: new url.URLParams({ phone }).toString(),
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse
}

interface User {
    id: number
    phone: string
    nickName: string
    createTime: Date
}

interface LoginResult {
    user: User
    token: string
}

export async function loginOrRegister(phone: string, verCode: string, password: string) {
    const request = http.createHttp()
    const params = new url.URLParams({ phone })
    if (password) {
        params.set('password', password)
    }
    if (verCode) {
        params.set('verCode', verCode)
    }
    const response = await request.request(`${apiOrigin}/api/user/loginOrRegister`, {
        method: http.RequestMethod.POST,
        extraData: params.toString(),
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse<LoginResult>
}

/** 保存用户信息
 *
 * - id 唯一标识用户
 * - phone 用户手机号，可于个人中心修改
 * - nickName 用户昵称，可于个人中心修改
 * - createTime 用户注册时间
 */
export function saveUserInfo(user: User) {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    data.putSync('id', user.id)
    data.putSync('phone', user.phone)
    data.putSync('nickName', user.nickName)
    data.putSync('createTime', user.createTime)
    data.flush()
}

export function getUserInfo(): User {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    return {
        id: data.getSync('id', ''),
        phone: data.getSync('phone', ''),
        nickName: data.getSync('nickName', ''),
        createTime: data.getSync('createTime', '')
    } as User
}

/**
 * 校验本地的 Token
 *
 * 通过 `success` 属性判断校验是否成功，
 * 如果校验失败，从 `message` 读取错误信息。
 * @returns { Promise<ApiResponse> }
 */
export async function checkToken(): Promise<ApiResponse> {
    const url = apiOrigin + '/api/user/checkToken'
    const request = http.createHttp()
    const response = await request.request(url, {
        header: { token: await getToken() },
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse
}

export function saveToken(token: string) {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    data.putSync('token', token)
    data.flush()
}

/**
 * 从用户首选项中获取 token 值
 * @returns
 */
export async function getToken(): Promise<string> {
    const data = await preferences.getPreferences(getContext(), 'user')
    const token = await data.get('token', '')
    return token as string
}