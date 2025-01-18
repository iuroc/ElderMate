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
    const response = await request.request(`${apiOrigin}/api/verCode/send`, {
        method: http.RequestMethod.POST,
        extraData: new url.URLParams({ phone }).toString(),
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse
}

interface User {
    uuid: string
    phone: string
    nickName: string
    createTime: Date
}

interface LoginResult {
    user: User,
    token: string
}

export async function loginOrRegister(phone: string, verCode: string, password: string) {
    const request = http.createHttp()
    const response = await request.request(`${apiOrigin}/api/user/loginOrRegister`, {
        method: http.RequestMethod.POST,
        extraData: new url.URLParams({ phone, verCode, password }).toString(),
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse<LoginResult>
}

/** 保存用户信息
 *
 * - uuid 唯一标识用户
 * - phone 用户手机号，可于个人中心修改
 * - nickName 用户昵称，可于个人中心修改
 * - createTime 用户注册时间
 */
export function saveUserInfo(user: User) {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    data.putSync('uuid', user.uuid)
    data.putSync('phone', user.phone)
    data.putSync('nickName', user.nickName)
    data.putSync('createTime', user.createTime)
    data.flush()
}

export function getUserInfo(): User {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    return {
        uuid: data.getSync('uuid', ''),
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
    const data = await preferences.getPreferences(getContext(), 'user')
    const token = await data.get('token', '')
    const url = apiOrigin + '/api/checkToken'
    const request = http.createHttp()
    const response = await request.request(url, {
        header: { token },
        expectDataType: http.HttpDataType.OBJECT
    })
    return response.result as ApiResponse
}

export function saveToken(token: string) {
    const data = preferences.getPreferencesSync(getContext(), { name: 'user' })
    data.putSync('token', token)
    data.flush()
}