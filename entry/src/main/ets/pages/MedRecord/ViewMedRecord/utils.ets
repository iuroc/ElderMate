import { http } from "@kit.NetworkKit"
import { apiOrigin } from "../../../common/config"
import { getToken } from "../../Login/utils"
import { url } from "@kit.ArkTS"
import { ApiResponse } from "../../../common/types"

export interface MedRecordInfoResultItem {
    id: number
    visitDate: string
    hospitalName: string
    medRecord: string
    images: Record<'url', string>[]
}

export async function getMedRecordInfo(id: number) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/medRecord/info', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        header: {
            token: await getToken(),
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: new url.URLParams({
            id: id.toString()
        }).toString()
    })
    const result = response.result as ApiResponse<MedRecordInfoResultItem>
    if (result.success) {
        return result.data
    }
    throw new Error(result.message)
}