import { http } from "@kit.NetworkKit"
import { url } from "@kit.ArkTS"
import { getToken } from "../Login/utils"
import { ApiResponse } from "../../common/types"
import { apiOrigin } from "../../common/config"
import { MedRecordListResultItem } from "./AddMedRecord/utils"

/**
 * 删除用药提醒
 *
 * @throws { Error }
 * @param id
 */
export async function deleteMedRecord(id: number) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/medRecord/delete', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        extraData: new url.URLParams({
            id: id.toString()
        }).toString(),
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

export async function getMedRecordList(page: number = 0, pageSize: number = 120) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/medRecord/list', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: new url.URLParams({
            page: page.toString(),
            pageSize: pageSize.toString()
        }).toString()
    })
    const result = response.result as ApiResponse<MedRecordListResultItem[]>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}