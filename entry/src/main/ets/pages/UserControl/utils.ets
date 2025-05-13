import { http } from "@kit.NetworkKit";
import { apiOrigin } from "../../common/config";
import { ApiResponse } from "../../common/types";
import { getLoginInfo, User, UserRole } from "../Login/utils";
import { url } from "@kit.ArkTS";


export interface UserInResponse {
    id: number
    phone: string
    nickName: string
    role: UserRole
    createTime: string
}

/**
 * 管理员功能，获取用户列表
 * @returns
 */
export async function getUsers() {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/user/list', {
        method: http.RequestMethod.GET,
        header: {
            token: await getLoginInfo()
        },
        expectDataType: http.HttpDataType.STRING
    })
    const result = JSON.parse(response.result as string) as ApiResponse<UserInResponse[]>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}

/**
 * 管理员功能，删除指定用户
 * @param userId
 * @returns
 */
export async function deleteUser(userId: number) {
    const request = http.createHttp()
    const params = new url.URLParams()
    params.set('userId', userId.toString())
    const response = await request.request(apiOrigin + '/api/user/delete/set', {
        method: http.RequestMethod.POST,
        extraData: params.toString(),
        header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            token: await getLoginInfo()
        },
        expectDataType: http.HttpDataType.STRING
    })
    const result = JSON.parse(response.result as string) as ApiResponse
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}