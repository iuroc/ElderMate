import { http } from "@kit.NetworkKit";
import { apiOrigin } from "../../common/config";
import { ApiResponse } from "../../common/types";
import { getLoginInfo, UserRole } from "../Login/utils";
import { url } from "@kit.ArkTS";

export async function updateInfo(config: UpdateInfoConfig) {
    const request = http.createHttp()
    const params = new url.URLParams()


    if (config.address) {
        params.set('address', config.address)
    }
    if (config.birthday) {
        params.set('birthday', config.birthday)
    }
    if (config.isMan != null) {
        params.set('isMan', config.isMan.toString())
    }
    if (config.callPhone) {
        params.set('callPhone', config.callPhone)
    }
    if (config.familyMessage) {
        params.set('familyMessage', config.familyMessage)
    }
    if (config.bloodType) {
        params.set('bloodType', config.bloodType)
    }
    if (config.idNumber) {
        params.set('idNumber', config.idNumber)
    }
    if (config.intro) {
        params.set('intro', config.intro)
    }
    if (config.name) {
        params.set('name', config.name)
    }
    const response = await request.request(apiOrigin + '/api/myInfo/update', {
        method: http.RequestMethod.POST,
        extraData: params.toString() || undefined,
        header: {
            token: await getLoginInfo(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        expectDataType: http.HttpDataType.OBJECT,
    })

    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

export async function getInfo() {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/myInfo/get', {
        method: http.RequestMethod.POST,
        header: {
            token: await getLoginInfo(),
        },
        expectDataType: http.HttpDataType.OBJECT,
    })
    const result = response.result as ApiResponse<GetInfoResult>
    if (result.success) {
        if (!result.data.callPhone) {
            result.data.callPhone = result.data.phone
        }
        return result.data
    }
    throw new Error(result.message)
}

export interface UpdateInfoConfig {
    address: string | null
    birthday: string | null
    isMan: number | null
    callPhone: string | null
    familyMessage: string | null
    bloodType: string | null
    idNumber: string | null
    intro: string | null
    name: string | null
}

export interface GetInfoResult extends UpdateInfoConfig {
    id: number
    nickName: string
    role: UserRole
    phone: string
    createTime: string
}